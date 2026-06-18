# Circuit Depth Lower Bounds from Layer Profiles

## Abstract

We develop a formal theory of Boolean circuit depth lower bounds using *layer profiles*, a combinatorial invariant that counts the number of gates at each depth level of a circuit. Working in the Lean 4 proof assistant with Mathlib, we formalize Boolean circuits as an inductive type and prove several non-trivial structural theorems: the layer profile conservation law (the profile sums to the internal gate count), the leaf count bound (leaf count ≤ 2^depth), the depth-from-leaves lower bound (depth ≥ log₂(leafCount)), the monotone circuit theorem (zero negation depth implies monotonicity), and the depth-0 sensitivity bound. We introduce the *exchange descent specification*, a novel structure connecting optimization theory to circuit complexity, and formulate a testable conjecture: the exchange descent problem with depth-k certificate in dimension d requires circuit depth at least (d − k − 1) · log₂(d). All theorems are machine-verified with no sorries.

**Keywords**: Boolean circuits, circuit complexity, depth lower bounds, layer profiles, exchange descent, formal verification

---

## 1. Introduction

Circuit complexity theory studies the resources — size, depth, fan-in — needed to compute Boolean functions by circuits of logic gates. Among these measures, *depth* is particularly significant because it corresponds to parallel time complexity: a circuit of depth d can be evaluated in d parallel steps.

Despite decades of effort, super-logarithmic depth lower bounds for explicit Boolean functions remain elusive in the general (unrestricted) circuit model. The strongest known results are either:
- For restricted models (monotone circuits, bounded-depth circuits, bounded fan-in), or
- For algebraic circuits (Baur-Strassen, degree-depth tradeoffs).

In this paper, we develop a formal framework for circuit depth analysis based on **layer profiles** — the function that assigns to each depth level the number of gates at that level. This invariant captures the "shape" of a circuit and provides a natural language for expressing information-theoretic constraints on computation.

### 1.1 Contributions

1. **Novel definitions**: `BoolCircuit` (Boolean circuits as an inductive type), `layerCount` (layer profile function), `ExchangeDescentSpec` (exchange descent problem specification), `negDepth` (negation depth), `sensitivity`, `leafCount`.

2. **Proved theorems** (all machine-verified in Lean 4):
   - Layer profile conservation: Σ layerCount(d) = internalSize
   - Leaf count bound: leafCount ≤ 2^depth
   - Depth from leaves: log₂(leafCount) ≤ depth
   - Work ≥ span: size ≥ depth + 1
   - Monotone circuit theorem: negDepth = 0 ⟹ monotone
   - Negation depth bound: negDepth ≤ depth
   - Depth-0 sensitivity: depth = 0 ⟹ sensitivity ≤ 1
   - Conjectured bound monotonicity: k₁ ≤ k₂ ⟹ bound(k₂) ≤ bound(k₁)
   - Conjectured bound lower bound: gap ≤ bound for d ≥ 2

3. **Testable conjecture**: Exchange descent circuit depth ≥ (d − k − 1) · log₂(d).

---

## 2. Boolean Circuit Model

### 2.1 Definition

We define Boolean circuits as an inductive type over `n` input variables:

```
inductive BoolCircuit (n : ℕ) : Type where
  | input : Fin n → BoolCircuit n
  | constTrue : BoolCircuit n
  | constFalse : BoolCircuit n
  | and : BoolCircuit n → BoolCircuit n → BoolCircuit n
  | or : BoolCircuit n → BoolCircuit n → BoolCircuit n
  | not : BoolCircuit n → BoolCircuit n
```

This represents circuits as syntax trees (formulas). While the formula model is less general than the DAG model (which allows gate reuse), it captures the essential depth-related phenomena and simplifies formal reasoning.

### 2.2 Semantics

Evaluation is defined by structural recursion:
- `eval(input i, v) = v(i)`
- `eval(and C₁ C₂, v) = eval(C₁, v) ∧ eval(C₂, v)`
- etc.

### 2.3 Structural Metrics

We define four key metrics:
- **Depth**: Longest root-to-leaf path length
- **Size**: Total gate count (leaves + internal)
- **Internal size**: Non-leaf gate count
- **Leaf count**: Number of leaf nodes

---

## 3. Layer Profiles

### 3.1 Definition

The **layer count** function `layerCount(C, d)` counts the number of internal gates at depth exactly `d` in circuit `C`. It is defined by structural recursion:

- Leaves contribute 0 at all depths
- An internal gate at the root contributes 1 at depth 0
- At depth d+1, a binary gate's count is the sum of its children's counts at depth d
- For NOT gates at depth d+1, the count equals the child's count at depth d

### 3.2 Conservation Law

**Theorem** (Layer Profile Conservation): For any circuit C,
```
  Σ_{d=0}^{depth(C)-1} layerCount(C, d) = internalSize(C)
```

*Proof sketch*: By structural induction. For leaf nodes, both sides are 0. For AND/OR gates, the range splits as {0} ∪ {1, ..., depth-1}. The root contributes 1 at depth 0, and the shifted sum decomposes into the sums for the two children. The key step uses `layerCount_zero_of_ge_depth` to extend each child's range to the maximum depth. The NOT case is similar but simpler (one child). □

### 3.3 Support Bound

**Theorem** (Layer Counts Vanish Beyond Depth): If `d ≥ depth(C)`, then `layerCount(C, d) = 0`.

This establishes that the layer profile has finite support, bounded by the circuit depth.

---

## 4. Depth Lower Bounds

### 4.1 Leaf Count Bound

**Theorem**: For any circuit C, `leafCount(C) ≤ 2^depth(C)`.

*Proof*: By structural induction. For leaves, leafCount = 1 ≤ 1 = 2^0. For binary gates at depth 1 + max(d₁, d₂), the leaf count is the sum of the children's leaf counts, each bounded by 2^dᵢ ≤ 2^max(d₁,d₂). The sum is at most 2 · 2^max(d₁,d₂) = 2^(1+max(d₁,d₂)). □

### 4.2 Depth from Leaf Count

**Theorem**: `log₂(leafCount(C)) ≤ depth(C)`.

This follows from the leaf count bound and monotonicity of logarithm.

### 4.3 Work ≥ Span

**Theorem**: `depth(C) + 1 ≤ size(C)`.

This is the Boolean analogue of the classical work-span inequality in parallel computing.

---

## 5. Negation Depth and Monotonicity

### 5.1 Negation Depth

The **negation depth** `negDepth(C)` counts the maximum number of NOT gates on any root-to-leaf path.

**Theorem**: `negDepth(C) ≤ depth(C)`.

### 5.2 Monotone Circuit Theorem

**Theorem**: If `negDepth(C) = 0`, then C computes a monotone Boolean function: for any inputs v ≤ w (pointwise), eval(C, v) = true implies eval(C, w) = true.

*Proof*: By structural induction. The base cases are immediate (constants, inputs). For AND: if both subcircuits are monotone and both output true on v, they both output true on w ≥ v. For OR: similarly, at least one subcircuit outputs true. The NOT case is vacuous since negDepth ≥ 1. □

This provides a clean algebraic characterization: the computational restriction of "no negations" corresponds precisely to the mathematical property of monotonicity.

---

## 6. Sensitivity

### 6.1 Definition

The **sensitivity** of circuit C at input v is the number of coordinates i such that flipping the i-th bit of v changes the output.

### 6.2 Depth-0 Sensitivity Bound

**Theorem**: If depth(C) = 0, then sensitivity(C, v) ≤ 1 for all v.

*Proof*: Depth-0 circuits are either constants (sensitivity 0) or single variables (sensitive to exactly one coordinate). □

This is the base case for inductive arguments relating sensitivity to depth.

---

## 7. Exchange Descent

### 7.1 Problem Specification

An **exchange descent specification** consists of:
- **Dimension** d ≥ 2: the number of coordinates
- **Certificate depth** k < d: how deeply we can certify optimality locally

The **gap** is g = d − k − 1, measuring how much of the problem structure is "non-local."

### 7.2 Conjectured Depth Lower Bound

**Conjecture**: Any Boolean circuit solving the exchange descent problem with depth-k certificate in dimension d has depth at least (d − k − 1) · ⌊log₂ d⌋.

We prove several structural properties of this bound:
- **Monotonicity**: If k₁ ≤ k₂, then bound(d, k₂) ≤ bound(d, k₁)
- **Trivial case**: If k ≥ d − 1, the bound is 0
- **Linear growth**: For d ≥ 2, the bound ≥ gap

### 7.3 Falsification Test

For d = 4, k = 0: the predicted bound is (4 − 0 − 1) · 2 = 6. To test this:
1. Encode the 4-dimensional exchange descent as a Boolean function
2. Formulate circuit depth minimization as a SAT problem
3. Search for circuits of depth ≤ 5

If such a circuit exists, the conjecture fails for d = 4.

---

## 8. Proof Methodology

All theorems are proved in Lean 4 using the Mathlib library. The proofs use:
- **Structural induction** on the `BoolCircuit` type (8 theorems)
- **Case analysis** and contradiction (sensitivity, depth positivity)
- **Multi-step calc chains** (leaf count bound, conjectured bound growth)
- **Finset arithmetic** (layer profile conservation, sensitivity bounds)

The file compiles with zero sorries and uses only standard axioms (propext, Classical.choice, Quot.sound).

---

## 9. Related Work

### Circuit Depth Lower Bounds
- Karchmer and Wigderson (1990): Communication complexity approach to circuit depth
- Razborov (1985): Super-polynomial monotone circuit size lower bounds
- Håstad (1986): Exponential lower bounds for bounded-depth circuits (parity)
- Huang (2019): Sensitivity conjecture resolution

### Algebraic Circuit Complexity
- Valiant (1979): VP and VNP complexity classes
- Baur and Strassen (1983): Degree-depth tradeoff for algebraic circuits
- The existing Catalog formalization: `AlgebraicCircuitComplexity.lean`

### Exchange Descent
- Bland (1977): Exchange descent methods in linear programming
- Borgwardt (1982): Average-case analysis of the simplex method

---

## 10. Algorithms

### 10.1 Layer Profile Computation (O(size) time)
Traverse the circuit tree, recording each internal gate's depth. The profile is the frequency histogram of depths.

### 10.2 Sensitivity Computation (O(n · 2^n) time)
For each of 2^n inputs, flip each of n bits and check if the output changes.

### 10.3 Conjectured Bound Evaluation (O(log d) time)
Simple arithmetic: (d − k − 1) · ⌊log₂ d⌋.

---

## 11. Discussion and Future Work

The layer profile framework provides a unified language for expressing circuit depth constraints. The conservation law and leaf count bounds are classical, but their formal integration with the exchange descent problem is new.

Key open directions:
1. **Prove the exchange descent conjecture** for specific small dimensions (d = 4)
2. **Extend to DAG circuits** — the formula model captures depth but misses size optimizations from gate sharing
3. **Connect to communication complexity** — Karchmer-Wigderson games provide an alternative depth lower bound technique
4. **Bridge to algebraic circuits** — relate the Boolean layer profile to the algebraic degree-depth tradeoff

---

## References

1. Razborov, A.A. "Lower bounds on the monotone complexity of some Boolean functions." *Doklady Akademii Nauk SSSR* 281 (1985).
2. Valiant, L.G. "Completeness classes in algebra." *STOC* (1979).
3. Karchmer, M., Wigderson, A. "Monotone circuits for connectivity require super-logarithmic depth." *STOC* (1990).
4. Huang, H. "Induced subgraphs of hypercubes and a proof of the sensitivity conjecture." *Annals of Mathematics* 190.3 (2019).
5. Baur, W., Strassen, V. "The complexity of partial derivatives." *Theoretical Computer Science* 22 (1983).
6. Håstad, J. "Almost optimal lower bounds for small depth circuits." *STOC* (1986).
