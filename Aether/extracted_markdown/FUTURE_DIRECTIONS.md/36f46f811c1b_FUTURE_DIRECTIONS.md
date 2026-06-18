# Future Directions: Novikov Self-Consistency as Fixed-Point Theory

## 1. Parametric Continuity of Self-Consistent Timelines

**Conjecture:** If `{f_t}_{t ∈ [0,1]}` is a continuous family of contracting causal maps
(i.e., `t ↦ f_t(x)` is continuous for each `x` and all `f_t` share a uniform contraction
factor `K < 1`), then the map `t ↦ x⋆(t)` sending each parameter to its unique fixed point
is continuous.

The key insight is that the perturbation stability bound `dist(x⋆(s), x⋆(t)) ≤ sup_x dist(f_s(x), f_t(x)) / (1 - K)` already proved in `Theorems.lean` gives *quantitative* continuity — the fixed-point map is Lipschitz in the parameter when the family is Lipschitz in the parameter. This upgrades from pointwise stability to a full parametric Banach theorem.

**Why now?** The perturbation stability theorem is already proved; the parametric extension requires formalizing continuous dependence on parameters in Mathlib's `ContractingWith` framework, which is a natural next step. The key challenge is handling the topology on the space of contracting maps.

## 2. Nonexpansive Causal Maps and Chronology Protection

**Conjecture:** There exist nonexpansive (Lipschitz-1) self-maps on complete bounded metric
spaces with no fixed points, formalizing Hawking's chronology protection conjecture as a
*failure* of the contraction condition.

The key insight is that the contraction hypothesis `K < 1` in Novikov's principle is *sharp*: for `K = 1`, fixed points may fail to exist (e.g., irrational rotation on the circle), and this boundary case corresponds to the physical threshold where chronology protection activates. The formalization would exhibit concrete counterexamples and prove that no weakening of the contraction condition suffices.

**Why now?** The current formalization makes the `K < 1` hypothesis explicit in every theorem. Constructing formal counterexamples at `K = 1` would sharply delineate the boundary of Novikov consistency and connect to the isometry theory already in Mathlib.

## 3. Multivalued Causal Maps and Set-Valued Fixed Points

**Conjecture:** For a set-valued contracting map `F : α → Set α` (where contractivity is
defined via the Hausdorff metric on closed subsets), there exists a fixed point `x` with
`x ∈ F(x)`, formalizing Novikov consistency for *nondeterministic* time-travel interactions.

The key insight is that Nadler's fixed-point theorem for multivalued contractions generalizes Banach's theorem to set-valued maps, and the physical interpretation is that when the causal interaction has multiple possible outcomes, at least one self-consistent history exists among them. This would require formalizing the Hausdorff metric on `Closeds α` in Lean.

**Why now?** Mathlib has `EMetric.hausdorffDist` and `TopologicalSpace.Closeds`. The gap is connecting these to a multivalued contraction principle. The physical motivation (quantum nondeterminism in CTCs) makes this particularly compelling.

## 4. Causal Maps on Infinite-Dimensional Spaces and Neural Network Fixed Points

**Conjecture:** For a neural network `N : ℝ^d → ℝ^d` with all layer weight matrices having
operator norm strictly less than 1, the recurrent fixed-point equation `N(x) = x` has a
unique solution, and gradient descent on `‖N(x) - x‖²` converges to it at a geometric rate.

The key insight is that the composition of linear contractions with 1-Lipschitz activations (like ReLU) is itself a contraction, so deep residual networks with small weights are causal maps in our framework. This bridges the Novikov formalization to the existing `ResNetLipschitz.lean` in the catalog and provides convergence guarantees for implicit-depth neural networks (DEQ models).

**Why now?** The `lipschitz_of_deriv_bounded` theorem already handles scalar differentiable maps. Extending to multivariate maps via the operator norm of the Jacobian would connect to Mathlib's `ContinuousLinearMap.opNorm` and the existing neural network formalization work in the catalog.

## 5. Tropical Novikov Consistency and Min-Plus Fixed Points

**Conjecture:** The tropical affine self-map formalized in `TropicalTimeTravel.lean` satisfies
a min-plus contraction condition under the sup-norm whenever the tropical matrix has all
entries strictly positive, and the resulting fixed point coincides with the shortest-path
solution of the corresponding weighted digraph.

The key insight is that the existing `TropicalTimeTravel.lean` formalization handles idempotent dynamics, while our metric-space Novikov theory handles contractive dynamics — these are dual perspectives on the same phenomenon, connected by the correspondence between min-plus algebra and metric geometry. Proving this bridge would unify two independent formalizations in the catalog.

**Why now?** Both `TropicalTimeTravel.lean` and `NovikovFixedPoint/Theorems.lean` are now proved. The bridge theorem requires showing that the sup-norm on `Fin n → ℝ` makes the tropical affine map a contraction, which is a concrete finite-dimensional calculation amenable to the existing Picard error bound theorem.
