# Future Directions: Multivariate Tower Complexity Theory

## Synthesis

The multivariate depth-separation theorem establishes that compositional depth and dimensional size are independent complexity resources for inverse-free EML expressions. This opens a two-dimensional complexity landscape where depth captures *architectural hardness* (how many sequential exponentiations are needed) and size captures *dimensional load* (how many variables must be mentioned). The directions below explore five frontiers emanating from this result: extending the exact lower bounds to approximate settings, strengthening the size bounds, incorporating inverse operations, connecting to tensor complexity, and pushing toward neural network depth separation. Each direction is specific enough to be falsified by a single counterexample or proved within a bounded formal effort.

---

## Direction 1: Approximate Depth Separation

**Conjecture:** For every n ≥ 2, k ≥ 1, and ε > 0, any inverse-free MVEMLExpr of depth < n that ε-approximates `iterExp n (∑ xᵢ)` on the unit cube [0,1]^k in sup-norm must have size ≥ f(n, ε) for some function f that grows as ε → 0.

**Test:** For n = 2, k = 2, enumerate depth-1 expressions of size ≤ 20 and compute their maximum error on a 100×100 grid over [0,1]². Record the minimum achievable error. If any depth-1 expression achieves error < 10⁻⁶, the conjecture (in its strong form) is refuted.

**Impact:** This would transform the exact lower bounds into robust approximation barriers, directly applicable to symbolic regression with finite-precision data.

**Catalog References:** `Pythagorean/MultivariateTower/Theorems.lean` — `depth_lower_bound_iterExp_sum`, `UEMLExpr.has_poly_tower_majorant`.

**Proof Strategy:** Use the polynomial tower majorant to show that depth-d expressions are uniformly bounded by iterExp d (C·x^N), which is uniformly separated from iterExp(d+1, x) on compact sets. The gap should yield a quantitative lower bound on approximation error.

**Domain Bridges:** Approximation theory, symbolic regression.

**Lineage:** Direct extension of the exact depth lower bound (Theorem 3.6).

**Ambition:** Grand challenge — would establish the first formal approximation barrier for multivariate analytic expression classes.

---

## Direction 2: Tight Size-Depth Product Bound

**Conjecture:** For any inverse-free MVEMLExpr computing `iterExp n (∑ xᵢ)` on the positive orthant, `size(e) ≥ n + k - 1`, with the optimal expression being `exp(exp(...(x₁ + x₂ + ... + xₖ)...))` of size 2n - 1 + 2k - 1.

**Test:** For n = 2, k = 3, enumerate all expressions of size ≤ 7 and depth ≥ 2, checking which ones compute `iterExp 2 (x₁ + x₂ + x₃)`. If any expression of size < 6 works, the conjecture is refuted.

**Impact:** Would establish a tight resource tradeoff between depth and size, analogous to the size-depth tradeoffs known for Boolean circuits.

**Catalog References:** `Pythagorean/MultivariateTower/Theorems.lean` — `joint_lower_bound`, `varSupport_card_le_size`.

**Proof Strategy:** Analyze the structure of optimal expressions. Show that the sum `x₁ + ... + xₖ` requires 2k-1 nodes, and each exp layer adds 1 node, for a total of 2k - 1 + n.

**Domain Bridges:** Circuit complexity, information theory.

**Lineage:** Strengthens the joint lower bound n + k ≤ depth + size.

**Ambition:** Solid extension — well-defined and achievable within current techniques.

---

## Direction 3: Depth Hierarchy with Inverses

**Conjecture:** The depth lower bound `n ≤ depth(e)` continues to hold when the expression language includes the inverse operation `inv(a) = 1/a`, i.e., for the full EML language.

**Test:** Search for depth-1 full EML expressions (with inv allowed) that compute iterExp 2 on a grid of positive reals. If found, the conjecture is false.

**Impact:** Would show that rational operations (division) do not collapse the exponential depth hierarchy, a much stronger statement than the inverse-free case.

**Catalog References:** `Catalog/Algebra/TightDepthHierarchy/Defs.lean` — `EMLExpr` (includes inv).

**Proof Strategy:** Extend the polynomial tower majorant to rational tower majorants. The key difficulty is that `1/exp(x)` can decrease, so the growth analysis must handle cancellation. However, `|eval e x|` is still bounded, and the absolute value growth should still be controlled.

**Domain Bridges:** Real algebraic geometry, o-minimal structures.

**Lineage:** Extends the inverse-free result to the full language.

**Ambition:** Grand challenge — the inverse operation fundamentally changes the growth analysis.

---

## Direction 4: Tensor Restriction Framework

**Conjecture:** For any linear map L : ℝᵐ → ℝᵏ with m ≥ k and rank k, if `e : MVEMLExpr m` computes `f ∘ L` and `f : (Fin k → ℝ) → ℝ` requires depth n in MVEMLExpr k, then e requires depth n in MVEMLExpr m.

**Test:** For k = 1, m = 2, L = projection onto first coordinate, verify that depth lower bounds for univariate functions transfer to bivariate expressions that ignore the second variable.

**Impact:** Would establish a general "tensor restriction" principle: complexity cannot decrease under dimensional restriction.

**Catalog References:** `Pythagorean/MultivariateTower/Theorems.lean` — `diagExpr`, `depth_diagExpr_le`.

**Proof Strategy:** Generalize diagExpr to arbitrary linear substitutions. The key property — that substitution does not increase depth — should hold for any affine map whose components are depth-0 expressions.

**Domain Bridges:** Tensor complexity, algebraic geometry, multilinear algebra.

**Lineage:** Generalizes the diagonal restriction (which is the special case L(t) = (t,...,t)).

**Ambition:** Solid extension — the diagonal case is already proved, and the general case requires only extending the substitution infrastructure.

---

## Direction 5: Depth Lower Bounds for Compositions with Monotone Functions

**Conjecture:** If g : ℝ → ℝ is strictly monotone and continuous, and `e : UEMLExpr` computes `g ∘ iterExp n` on positive reals, then `depth(e) ≥ n`.

**Test:** Try g(x) = log(x) (which is the inverse of exp). If a depth-(n-1) expression computes log ∘ iterExp n = iterExp (n-1) on positive reals, this would contradict the conjecture (and is actually a special case of the existing theorem). For non-trivial g like g(x) = x², search for depth-1 expressions computing x² ∘ exp(exp(x)) = exp(2·exp(x)) on a grid.

**Impact:** Would show that pre-composition with monotone functions preserves depth complexity, establishing a broad invariance principle.

**Catalog References:** `Pythagorean/MultivariateTower/Theorems.lean` — `depth_lower_bound_univariate`, `UEMLExpr.has_poly_tower_majorant`.

**Proof Strategy:** The polynomial tower majorant bounds |eval e x| ≤ iterExp d (C·x^N). If e computes g ∘ iterExp n, then g(iterExp n x) ≤ iterExp d (C·x^N). For g strictly monotone and unbounded, this forces n ≤ d by the growth separation.

**Domain Bridges:** Real analysis, dynamical systems.

**Lineage:** Extends the depth lower bound from iterExp n to a broader class of target functions.

**Ambition:** Solid extension — follows from the existing growth analysis with a moderate amount of additional work.
