# Future Directions: Tropical Complexity Theory

## Overview

The weighted BP-to-tropical-circuit simulation theorem, now formalized generically over any ordered additive monoid with top, opens a systematic research program connecting complexity theory, tropical geometry, optimization, and machine learning. Below are five concrete next steps, each with specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Max-Plus / Min-Plus Duality Theorem

### Goal
Formalize the syntactic duality between min-plus and max-plus tropical circuits, and prove that the simulation theorem transfers automatically between conventions.

### Hypothesis
For any `α` with a negation-like involution `σ : α → α` satisfying `σ(a + b) = σ(a) + σ(b)` and `σ(inf a b) = sup (σ a) (σ b)`, the simulation theorem for min-plus circuits implies an identical theorem for max-plus circuits with the same operation bound.

### Proof Strategy
1. Define a `TropicalDuality` typeclass capturing the involution interface.
2. Construct a functor from min-plus circuits to max-plus circuits via the involution.
3. Show the functor preserves operation count and commutes with evaluation.
4. For `WithTop ℝ`, the involution is `a ↦ -a` (with appropriate handling of `⊤`).

### Cross-Domain Impact
- **Optimization**: max-plus is natural for longest-path / maximum-throughput problems.
- **Statistical physics**: max-plus corresponds to ground-state energy computation.
- **Control theory**: max-plus linear systems model discrete-event systems.

---

## Direction 2: Piecewise-Linear Polyhedrality of BP Functions

### Goal
Prove that every weighted branching program over `ℝ` computes a piecewise-linear function (when the edge weights depend affinely on the input).

### Hypothesis
If a width-`w`, depth-`d` BP has edge weights of the form `a · x + b` (affine in input `x ∈ ℝⁿ`), then the output function `x ↦ eval(P, x)` is piecewise linear with at most `wᵈ` linear pieces.

### Proof Strategy
1. Define `AffineBP w d n` where edge weights are affine forms on `ℝⁿ`.
2. Prove by induction on depth that `tropReachCost` at each layer is a pointwise minimum of finitely many affine functions.
3. Use the existing normal-form extraction from `Tropical.Circuits.Defs` to connect circuit representations to affine-form decompositions.
4. Bound the number of pieces by tracking the combinatorial explosion through layers.

### Cross-Domain Impact
- **Tropical geometry**: BP-computable functions define tropical hypersurfaces.
- **Neural networks**: piecewise-linear functions are exactly ReLU network outputs; this creates a formal bridge between BP complexity and neural network expressivity.
- **Convex optimization**: min-of-affine functions are concave; this connects to LP duality.

---

## Direction 3: Generic Semiring-Interface Platform Theorem

### Goal
Identify the minimal algebraic axioms used in the simulation and refactor the theorem to depend only on a custom typeclass `TropicalSemiring`.

### Hypothesis
The simulation proof uses exactly five operations: `⊤` (absorbing element for `inf`), `0` (neutral element for `+`), `+` (cost accumulation), `inf` (path selection), and `Finset.inf` (finite aggregation). No commutativity, associativity, or distributivity of `+` over `inf` is needed for the *construction* — only for semantic equivalence with DP.

### Proof Strategy
1. Audit the existing generic proof to identify every typeclass method actually used.
2. Define `class TropicalSemiring (α : Type*) extends SemilatticeInf α, OrderTop α, AddMonoid α`.
3. Prove the simulation theorem once over `TropicalSemiring`.
4. Provide instances for `WithTop ℕ`, `WithTop ℤ`, `WithTop ℝ`, `ENNReal`, `EReal`, and `Tropical ℝ` (from Mathlib).

### Cross-Domain Impact
- **Algebra**: creates a reusable tropical semiring interface for Mathlib.
- **Formal methods**: a platform theorem that generates simulation results for any new semiring instance automatically.
- **Coding theory**: Viterbi semirings (probability + min) become instant corollaries.

---

## Direction 4: Tropical Circuit Lower Bounds via BP Width-Depth Tradeoffs

### Goal
Use the simulation theorem in reverse: prove that known BP lower bounds yield tropical circuit lower bounds.

### Hypothesis
The permutation matrix function (computing the tropical determinant of a permutation's weight matrix) requires tropical circuits of size `Ω(n²)` because any BP computing it needs width `Ω(n)` or depth `Ω(n)`.

### Proof Strategy
1. Formalize the tropical permanent / determinant as a specific BP computation.
2. Apply the lower bound transfer theorem: `K ≤ 2w²d + w`.
3. Use known communication complexity lower bounds for the permutation routing problem to establish that `w · d = Ω(n²)`.
4. Conclude `circuit_size ≥ K = Ω(n²)`.

### Cross-Domain Impact
- **Complexity theory**: first formalized tropical circuit lower bounds.
- **Combinatorial optimization**: hardness of computing shortest-path permanents.
- **Algebraic complexity**: connects to Valiant's algebraic complexity program but in the tropical setting.

---

## Direction 5: Entropy-Regularized Soft-Min Semantics

### Goal
Extend the simulation theorem to the "temperature-`β`" regime where `min` is replaced by the log-sum-exp (soft-min) operator, and prove convergence to the tropical limit as `β → ∞`.

### Hypothesis
Define `softMin_β(a, b) = -β⁻¹ · log(exp(-βa) + exp(-βb))`. Then:
1. For each finite `β > 0`, the soft-min BP computes a smooth function.
2. As `β → ∞`, the soft-min BP output converges pointwise to the tropical (hard-min) BP output.
3. The simulation theorem holds for soft-min circuits with the same operation bound `2w²d + w`.

### Proof Strategy
1. Define `SoftMinBP β w d` with the soft-min recurrence.
2. Prove monotone convergence of `softMin_β` to `min` as `β → ∞` using existing Mathlib analysis.
3. The circuit simulation is identical (same construction, same bound) because it is purely structural — it doesn't depend on the specific operation semantics.
4. Prove the convergence theorem: `∀ ε > 0, ∃ β₀, ∀ β > β₀, |softEval β P - tropEval P| < ε`.

### Cross-Domain Impact
- **Statistical physics**: soft-min is the free energy; tropical limit is zero-temperature.
- **Machine learning**: log-sum-exp is the transformer attention mechanism's core operation.
- **Information theory**: connects channel capacity computation to tropical circuits.
- **Reinforcement learning**: soft Bellman equations (entropy-regularized MDPs) are exactly soft-min BPs.

---

## Research Infrastructure

### Recommended Lean Modules to Build
1. `Tropical.Semiring` — typeclass for tropical semirings with key instances.
2. `Tropical.Duality` — min-plus ↔ max-plus duality functor.
3. `Tropical.Polyhedrality` — piecewise-linear structure of BP functions.
4. `Tropical.LowerBounds` — circuit lower bounds via BP tradeoffs.
5. `Tropical.SoftMin` — temperature-parameterized soft-min semantics.

### Key Mathlib Dependencies to Watch
- `Mathlib.Algebra.Tropical.Basic` — existing tropical type wrapper.
- `Mathlib.Order.WithBot` / `WithTop` — extended ordered types.
- `Mathlib.Analysis.SpecialFunctions.Log.Basic` — for soft-min convergence.
- `Mathlib.Topology.Order.Basic` — for limit arguments.

### Team Directive
Each direction above is designed to be pursued independently by a small team. Directions 1-3 are algebraic/structural and can proceed in parallel. Direction 4 requires external lower bound results. Direction 5 requires analysis infrastructure. The recommended order of attack is: 3 → 1 → 2 → 4 → 5, but any ordering that respects the dependency 3→(1,2) is viable.
