# Future Directions: Multivariate EML Tower Complexity

## Synthesis

The multivariate tower complexity theory developed here opens five interconnected research directions. At its core, the theory establishes that tower depth is a geometric invariant of symbolic expressions—dimension-invariant and robust under coordinate aggregation. The natural next steps push this rigidity in three ways: (1) making the size bounds tight, (2) extending from exact to approximate representation, and (3) bridging to other complexity measures (tensor rank, circuit depth, learning-theoretic dimension). Each direction below builds on the formal infrastructure (MVEMLExpr, restrictExpr, varSupport) and the proved theorems (depth lower/upper bounds, support theorem, size lower bound, monotonicity).

---

## Direction 1: Tight Size Bounds for Multivariate Tower Functions

**Conjecture.** For every k ≥ 1 and n ≥ 0, the minimum size of a MVEMLExpr(k) computing iterExp(n, FinSum(x)) on positive inputs is exactly 2n + 2k − 1.

**Test.** Exhaustive enumeration for (n, k) ∈ {(1,2), (2,2), (1,3), (2,3)}. For each pair, enumerate all expressions of size up to 2n + 2k − 2 and verify none matches iterExp(n, FinSum(x)) on a dense positive grid.

**Impact.** Would complete the quantitative complexity picture, giving both exact depth and exact size. The gap between the current lower bound (n + k) and the construction size (2n + 2k − 1) suggests there is a structural counting argument waiting to be formalized.

**Catalog References.** `Pythagorean/MultiVariableTower/MVTower.lean` (mv_size_lower_bound_iterExp_sum, mkIterExpSum_depth), `Pythagorean/SizeDepthTradeoff/Theorems.lean` (size_lower_bound_iterExp).

**Proof Strategy.** Refine the counting argument: each exp node contributes 1 to depth and 1 to size, each variable leaf contributes 1 to size, and the internal binary nodes (add/mul) connecting the k variable leaves contribute k − 1 additional nodes. Total: n + k + (k − 1) = n + 2k − 1 for n ≥ 1. Prove this by induction on n + k.

**Domain Bridges.** Arithmetic circuit complexity (gate count = size), Kolmogorov complexity (expression = program).

**Lineage.** Builds directly on Theorem 3 (size lower bound) of the current work.

**Ambition.** Solid extension — completes an open quantitative question.

---

## Direction 2: Approximation-Depth Tradeoffs

**Conjecture.** For any ε > 0 and any MVEMLExpr(k) of depth d < n, the sup-norm error of approximating iterExp(n, FinSum(x)) on [δ, R]^k satisfies |e.eval(x) − iterExp(n, FinSum(x))| > iterExp(n−1, δ·k) for some x, when R is sufficiently large relative to δ, n, k.

**Test.** For n = 3, k = 2, d = 2: numerically optimize depth-2 expressions (with free parameters) to minimize max error on [0.1, 2.0]². Report the achieved minimum error and compare with iterExp(2, 0.2).

**Impact.** Would establish that the depth barrier is not just an exact-representation phenomenon but a genuine approximation-theoretic obstruction. This would bridge EML complexity to approximation theory and learning theory.

**Catalog References.** `Pythagorean/MultiVariableTower/MVTower.lean` (sv_depth_majorant, iterExp_escapes_lower_level).

**Proof Strategy.** Use the growth-rate argument: depth-d expressions grow at most as fast as iterExp(d, ·), so on a sufficiently large domain, the error must be at least iterExp(n, ·) − iterExp(d, ·), which is enormous.

**Domain Bridges.** Approximation theory, PAC learning (model class capacity), neural network expressivity.

**Lineage.** Extends Theorems 1–2 from exact to approximate setting.

**Ambition.** Grand challenge — would create a new subfield of "compositional approximation theory."

---

## Direction 3: Tower Rank as a Semantic Invariant

**Conjecture.** Define towerRank(e) as the maximum number of exp nodes on any root-to-leaf path. Then for any inverse-free MVEMLExpr computing iterExp(n, FinSum(x)) on positive inputs, towerRank(e) ≥ n. Moreover, towerRank coincides with minimum depth on the subclass generated from affine forms by repeated exponentiation and multiplication.

**Test.** For all expressions up to size 10 with k = 2: compute towerRank and depth, verify towerRank ≤ depth always, and check whether towerRank = depth for the affine-tower subclass.

**Impact.** Would identify towerRank as the "true invariant" responsible for depth lower bounds, isolating it from incidental features of the expression tree structure.

**Catalog References.** `Pythagorean/MultiVariableTower/MVTower.lean` (depth_lt_size, mv_depth_lower_bound_iterExp_sum), `Algebra/TightDepthHierarchy/Defs.lean` (growthRank).

**Proof Strategy.** Prove towerRank ≤ depth by structural induction. For the lower bound, use repeated "logarithmic peeling": if towerRank < n, then every root-to-leaf path passes through < n exp nodes, so the function can be decomposed into compositions of fewer than n exponentials plus polynomial/multiplicative terms.

**Domain Bridges.** Algebraic complexity (Strassen's tensor rank), real algebraic geometry (o-minimal stratification).

**Lineage.** Strengthens Theorem 1 by identifying a finer invariant.

**Ambition.** Grand challenge — would define a new complexity measure with structural significance.

---

## Direction 4: Multivariate Monotonicity and Positive Geometry

**Conjecture.** Every inverse-free MVEMLExpr with nonneg constants is not only coordinatewise monotone on the positive cone, but also *log-convex* in each coordinate on the positive cone. Moreover, iterExp(n, FinSum(x)) is Schur-convex on the positive cone.

**Test.** For random expressions of size ≤ 8 with nonneg constants: numerically verify log-convexity by checking that log(e.eval) is convex along each coordinate axis. For iterExp(n, FinSum): verify Schur-convexity by checking majorization inequalities on random point pairs.

**Impact.** Would connect EML complexity to convex geometry and majorization theory. Schur-convexity would imply that the tower function is maximized at the diagonal point (all coordinates equal), connecting to mean-field theory in physics.

**Catalog References.** `Pythagorean/MultiVariableTower/MVTower.lean` (mv_eval_le_eval_of_le, mv_eval_nonneg_of_nonneg_consts).

**Proof Strategy.** Log-convexity: exp(f) is log-convex when f is convex. Products of log-convex functions are log-convex. Induction on expression structure. Schur-convexity: FinSum is a symmetric function, and iterExp preserves the ordering induced by majorization.

**Domain Bridges.** Convex optimization, statistical physics (partition functions), information theory (entropy).

**Lineage.** Extends Theorem 4 (monotonicity) to richer geometric properties.

**Ambition.** Solid extension with potential for grand-challenge connections.

---

## Direction 5: Depth Separation for Product Aggregation

**Conjecture.** For k ≥ 2 and n ≥ 1, the minimum depth of a MVEMLExpr(k) computing iterExp(n, ∏ᵢ xᵢ) on positive inputs is exactly n.

**Test.** For k = 2, n = 2: enumerate depth-1 expressions and verify none matches iterExp(2, x₀ · x₁) on a positive grid. For k = 2, n = 3: similarly with depth ≤ 2.

**Impact.** Would show that the depth barrier applies not just to additive aggregation (FinSum) but also to multiplicative aggregation, suggesting a universal principle: tower depth is invariant under all "natural" aggregation operations.

**Catalog References.** `Pythagorean/MultiVariableTower/MVTower.lean` (mv_depth_lower_bound_iterExp_sum — proof architecture via restriction).

**Proof Strategy.** Adapt the restriction technique: fix all but one variable to 1, obtaining iterExp(n, t · 1 ⋯ 1) = iterExp(n, t). The rest follows from the single-variable lower bound. The key difference from the additive case is that the restricted function is iterExp(n, t) rather than iterExp(n, t + c), which is actually simpler.

**Domain Bridges.** Tensor complexity (rank of multilinear forms), quantum information (product states vs entangled states).

**Lineage.** Direct generalization of Theorem 1 to a different aggregation operation.

**Ambition.** Solid extension — likely provable with existing techniques.
