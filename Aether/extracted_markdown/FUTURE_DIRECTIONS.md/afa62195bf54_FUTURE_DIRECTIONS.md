# Future Directions: Size–Depth Tradeoffs for EML Expressions

## Synthesis

The formally verified size–depth tradeoff theory establishes a quantitative bridge between expression syntax and asymptotic growth behavior. The current results show linear size lower bounds for the iterated exponential family and absolute impossibility at bounded depth. This foundation opens several directions: tightening the size gap, extending to richer expression languages, connecting to approximate computation, and building bridges to circuit complexity and symbolic regression. Each direction below builds directly on the verified catalog theorems and is designed to be both ambitious enough to advance the field and specific enough to admit concrete tests.

---

## Direction 1: Tight Size Characterization for iterExp

**Conjecture.** The minimum size of an inverse-free EML expression computing iterExp(n) on positive reals is exactly 2n + 1, matching the canonical construction.

**Test.** Enumerate all inverse-free EML expressions of size < 2n+1 for small n (n = 1, 2, 3, 4) and verify that none computes iterExp(n) on 100 positive sample points. If a smaller expression is found, the conjecture is false.

**Impact.** This would establish the canonical construction as uniquely optimal, showing that iterExp(n) has a single "natural" representation in EML. It would be a rare example of a tight expression complexity result.

**Catalog References.**
- `SizeDepthTradeoff.lean`: `size_lower_bound_iterExp` (current bound: n+1)
- `SizeDepthTradeoff.lean`: `emlExprIterExp_size` (canonical: 2n+1)
- `SizeDepthTradeoff.lean`: `iterExp_size_characterization`

**Proof Strategy.** Strengthen the majorant analysis to track not just the tower height and polynomial degree but also the detailed coefficient structure. Show that the eml operation introduces irreducible size overhead at each level, forcing the total to be at least 2 per level.

**Domain Bridges.** Circuit complexity (gate elimination), Kolmogorov complexity (incompressibility), symbolic regression (formula irreducibility).

**Lineage.** Direct extension of `size_lower_bound_iterExp`.

**Ambition.** ★★★★☆ — challenging but focused; the gap is only a factor of 2.

---

## Direction 2: Size–Depth Tradeoffs with Inversions

**Conjecture.** Allowing inversions (the full EML) does not reduce the minimum depth required for iterExp(n). That is, even with inv nodes, depth n is necessary for iterExp(n).

**Test.** Search for EML expressions (with inversions allowed) of depth < n that compute iterExp(n) for small n. Evaluate candidates on 50 positive points with varying magnitudes (x ∈ {0.01, 0.1, 0.5, 1, 2, 5, 10}). A match at all points would disprove the conjecture.

**Impact.** This would extend the depth hierarchy from the inverse-free fragment to the full EML, establishing a much stronger result. Inversions introduce the possibility of cancellation and rational function manipulation, which could potentially enable depth reduction.

**Catalog References.**
- `Algebra/TightDepthHierarchy/Theorems.lean`: `no_invFree_lowDepth_represents_iterExp`
- `Algebra/TightDepthHierarchy/Defs.lean`: `HasPolyTowerMajorant`

**Proof Strategy.** Extend the majorant analysis to handle inversions. The key challenge is that 1/f can have growth rate inversely related to f, potentially enabling cancellations that "simulate" deeper towers. Show that such cancellations are eventually dominated.

**Domain Bridges.** Algebraic complexity (rational function complexity), differential algebra (Liouvillian functions), dynamical systems (ergodic theory of iterated maps).

**Lineage.** Extension of the inverse-free depth hierarchy.

**Ambition.** ★★★★★ — a grand challenge; inversions fundamentally change the algebraic structure.

---

## Direction 3: Approximate Computation Lower Bounds

**Conjecture.** For any fixed ε > 0 and D < n, no inverse-free depth-D expression e satisfies |eval(e, x) − iterExp(n, x)| < ε · iterExp(n, x) for all sufficiently large x.

**Test.** For D = 2 and n = 4, enumerate depth-2 expressions of size up to 20 and compute the relative error max_x |eval(e, x)/iterExp(4, x) − 1| on a grid of 1000 points in [1, 10]. If the minimum relative error is < 0.01 for any expression, the conjecture is challenged.

**Impact.** Extends the impossibility from exact to approximate computation, which is more relevant for practical applications like symbolic regression and neural network expressivity.

**Catalog References.**
- `SizeDepthTradeoff.lean`: `iterExp_depth_bounded_impossible`
- `SizeDepthTradeoff.lean`: `noInv_quantitative_majorant`

**Proof Strategy.** Use the quantitative majorant to show that depth-D expressions are eventually dominated by iterExp(D+1), while iterExp(n) grows much faster. The relative error iterExp(n,x)/iterExp(D,C·x^N) → ∞ as x → ∞, so no multiplicative approximation is possible.

**Domain Bridges.** Approximation theory, neural network expressivity, numerical analysis.

**Lineage.** Quantitative strengthening of `iterExp_depth_bounded_impossible`.

**Ambition.** ★★★☆☆ — accessible extension with high impact.

---

## Direction 4: Multi-Variable Tower Functions

**Conjecture.** For the multi-variable EML (with variables x₁, ..., x_k), the minimum depth for computing iterExp(n, x₁ + x₂ + ... + x_k) remains n, and the minimum size grows at least as Ω(n + k).

**Test.** For k = 2 and n = 3, enumerate two-variable inverse-free expressions of depth ≤ 2 and check whether any matches iterExp(3, x+y) on a 10×10 grid of positive points. No match should be found.

**Impact.** Multi-variable extensions are essential for applications to symbolic regression on multi-dimensional data. The interaction between the number of variables and the tower height creates a richer complexity landscape.

**Catalog References.**
- `SizeDepthTradeoff.lean`: `size_lower_bound_iterExp`
- `Algebra/TightDepthHierarchy/Defs.lean`: `EMLExpr` (currently single-variable)

**Proof Strategy.** Generalize the evaluation semantics to x : ℝ^k and extend the majorant analysis. The key insight is that the tower height is determined by the nesting structure, not the number of variables.

**Domain Bridges.** Multivariate approximation theory, tensor complexity, algebraic geometry.

**Lineage.** Generalization of the single-variable theory.

**Ambition.** ★★★☆☆ — moderate difficulty, high practical relevance.

---

## Direction 5: Information-Theoretic Characterization of Expression Entropy

**Conjecture.** The number of semantically distinct inverse-free EML expressions of size s and depth D over constants from a finite set K is at most |K|^s · s^O(1), and this bound is tight up to polynomial factors.

**Test.** For K = {0, 1}, D = 2, enumerate all expressions of each size s ∈ {1, ..., 8} and count the number of semantically distinct functions (using evaluation on 20 test points as a proxy for semantic identity). Plot log(count) vs s and check for linear growth with slope ≤ log|K| + O(log s).

**Impact.** This would establish a precise information-theoretic characterization of the "entropy" of the expression language — how many bits of information each syntax node contributes. Combined with the lower bounds on iterExp, it would give a Shannon-style proof that most analytic functions of high tower complexity require large expressions.

**Catalog References.**
- `SizeDepthTradeoff.lean`: `bounded_profiles_card`
- `SizeDepthTradeoff.lean`: `shannon_counting_impossibility`

**Proof Strategy.** Count the number of binary tree shapes of size s (Catalan numbers), multiply by the number of label assignments (|K| choices per const node, bounded choices per operation node), and prove that semantic equivalence classes are not too small.

**Domain Bridges.** Information theory (Shannon entropy), coding theory, descriptive complexity, learning theory (VC dimension).

**Lineage.** Extension of `bounded_profiles_card`.

**Ambition.** ★★★★☆ — requires bridging syntax counting with semantic analysis.
