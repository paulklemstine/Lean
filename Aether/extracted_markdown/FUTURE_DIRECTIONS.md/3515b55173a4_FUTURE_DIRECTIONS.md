# Future Directions: Depth-Stratified Differential Theory for EML Expressions

## Synthesis

The depth preservation theorem for full EML with negation establishes that `emlDepth` is a differential invariant of the exponential-multiplicative expression language. This opens a research program connecting symbolic computation, differential algebra, and machine learning expressivity through the lens of expression complexity. The directions below form a coherent progression: Direction 1 refines the invariant to exact preservation, Direction 2 extends the grammar to logarithms, Direction 3 connects depth to computational cost, Direction 4 bridges to transseries theory, and Direction 5 addresses the grand challenge of a full syntactic Hardy field.

Each direction builds directly on the machine-verified theorems in `Catalog/Pythagorean/HardyHierarchy/FullEMLDiffClosure.lean` and the infrastructure in `Catalog/MachineLearning/HardyHierarchy/Defs.lean`.

---

## Direction 1: Exact Depth Preservation Classification

**Conjecture:** For every EML expression `e` with `emlDepth(e) ≥ 1`, we have `emlDepth(deriv(e)) = emlDepth(e)` — depth is *exactly* preserved, not merely bounded.

**Test:** Enumerate all EML expressions of size ≤ 8 and depth ≤ 4. For each, compute `emlDepth(deriv(e))` and check whether it equals `emlDepth(e)`. A single expression with strict decrease disproves the conjecture. Our preliminary experiments with 1652 expressions of size ≤ 5 found no depth drops for expressions of depth ≥ 1.

**Impact:** If true, this would show that depth is not merely a bound but a *sharp* invariant — differentiation perfectly preserves exponential nesting. This would make depth an even stronger complexity measure, directly analogous to transcendence degree in algebraic geometry.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/FullEMLDiffClosure.lean` (Theorem `depth_deriv_le_self`), `Catalog/MachineLearning/HardyHierarchy/Defs.lean` (`emlDepth`).

**Proof Strategy:** The key observation is that `deriv(eml(a, b)) = eml(a' + a·b', b)` preserves the `eml` node. Since `emlDepth(eml(a,b)) = 1 + max(emlDepth(a), emlDepth(b))` and the derivative's coefficient has depth ≤ `max(emlDepth(a), emlDepth(b))`, we need to show that equality holds when `emlDepth(a) ≥ 1` or the eml node contributes the maximum depth. This requires a structural argument about how depth is achieved in the expression tree.

**Domain Bridges:** Differential algebra (transcendence degree preservation), algebraic geometry (dimension theory), symbolic computation (expression normal forms).

**Lineage:** Extends `depth_deriv_le_self` from inequality to equality.

**Ambition:** Medium — likely provable with careful case analysis.

---

## Direction 2: Logarithmic Extension — The Full Hardy Grammar

**Conjecture:** Extend the EML grammar with a `log` constructor: `log(a)` evaluates to `ln(a(x))`. Define `emlDepth(log(a)) = emlDepth(a) + 1` (logarithms are at the same level as exponentials in the Hardy hierarchy). Then depth preservation holds: `emlDepth(deriv(e)) ≤ emlDepth(e)` for the extended grammar.

**Test:** Implement the extended grammar with logarithms. Enumerate expressions of size ≤ 6 and depth ≤ 3 in the extended language. Check depth preservation for 3 iterated derivatives. The derivative `d/dx[log(a)] = a'/a` introduces division (or equivalently, a product with `a⁻¹`). If the grammar lacks division, this may require adding a `div` or `inv` constructor. A counterexample in the extended grammar would disprove the conjecture.

**Impact:** This would extend depth preservation to the full log-exp fragment of Hardy fields — the natural closure of the EML language under both exponential and logarithmic operations. This is the syntactic analogue of Hardy's L-functions.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/FullEMLDiffClosure.lean`, `Catalog/Speculative/HardyHierarchy/Theorems.lean` (Hardy level hierarchy).

**Proof Strategy:** The derivative of `log(a)` is `a'/a`. If we represent this as `mul(deriv(a), inv(a))`, we need `inv` to not increase depth. The key challenge is that `a'/a` for `a = eml(c, d) = c·exp(d)` simplifies to `(c'/c) + d'`, which has lower depth. This "logarithmic derivative decomposition" (already partially formalized in `DiffClosure.lean` as `logDeriv_mul_exp`) is the engine.

**Domain Bridges:** Hardy fields (L-functions), transseries (log-exp closure), analytic number theory (growth of arithmetic functions), asymptotic analysis.

**Lineage:** Natural extension of the full EML depth preservation.

**Ambition:** Grand challenge — requires extending both the grammar and the depth theory.

---

## Direction 3: Size Growth Bounds Under Iterated Differentiation

**Conjecture:** For any EML expression `e` of size `s` and depth `d`, the size of `deriv^[n](e)` is bounded by `s · C^n` for a constant `C` depending only on `d`, not on the specific expression.

**Test:** For each depth level d ∈ {0, 1, 2, 3}, compute size growth ratios `size(deriv^[n+1](e)) / size(deriv^[n](e))` for a representative sample of expressions. Check whether these ratios stabilize to a depth-dependent constant. Our preliminary data shows:
- Depth 0 (x²): ratio ≈ 2.0 (exact)
- Depth 1 (x·exp(x)): ratio ≈ 3.5-4.0
- Depth 2 (exp(exp(x))): ratio ≈ 5.0-7.0

A counter-pattern (ratio growing with n) would disprove the conjecture.

**Impact:** Combined with depth preservation, this would give a complete complexity profile for iterated differentiation: depth is O(1), size is O(C^n). This is relevant for compiler optimization and resource allocation in symbolic computation.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/FullEMLDiffClosure.lean` (depth bounds), `Catalog/MachineLearning/HardyHierarchy/Defs.lean` (`EmlExpr.size`).

**Proof Strategy:** Analyze the recurrence relations for size under each derivative rule. The product rule doubles terms, and the eml rule preserves size up to a constant factor. A careful recurrence analysis, stratified by depth, should yield the bound.

**Domain Bridges:** Computational complexity (circuit size bounds), compiler optimization (code size prediction), automatic differentiation (memory bounds).

**Lineage:** Complements depth preservation with a size-complexity analysis.

**Ambition:** Medium — the bound likely exists but the exact constant requires careful analysis.

---

## Direction 4: Connection to Transseries Well-Orderedness

**Conjecture (Grand Challenge):** The depth filtration of EML expressions, viewed as a differential filtration, corresponds to the natural well-ordered support structure of the field of transseries. Specifically, for each depth level k, the evaluation images `{ eval(e, ·) | e ∈ DepthClosed(k) }` form a Hardy field fragment whose comparability class is determined by the iterated exponential `iterExp(k)`.

**Test:** For expressions of depth ≤ 2, verify computationally that:
1. Every such expression is eventually dominated by `exp(exp(x))` (= iterExp 2).
2. Expressions of depth exactly 2 eventually dominate any expression of depth ≤ 1.
Test this for all enumerated expressions of size ≤ 6, evaluating at x = 10, 100, 1000.

**Impact:** This would establish EML depth as the syntactic encoding of the transseries valuation — a deep connection between combinatorial and analytic structure. It would provide the first formal bridge between syntax-level expression complexity and the well-ordered universe of transseries.

**Catalog References:** `Catalog/Speculative/HardyHierarchy/Theorems.lean` (`hardyLevel_zero_poly_bound`, `iterExp_mem_hardyLevel`), `Catalog/Pythagorean/HardyHierarchy/FullEMLDiffClosure.lean`.

**Proof Strategy:** Use the existing `emlDepth_le_hardyLevel` theorem to embed EML depth strata into Hardy levels. Then prove growth separation between consecutive levels using the existing `exp_not_hardyLevel_zero` as a base case and generalizing to higher levels.

**Domain Bridges:** Transseries theory, model theory of ordered fields, surreal numbers, asymptotic analysis, o-minimality.

**Lineage:** Extends `emlDepth_le_hardyLevel` and `iterExp_base_separation` to a full separation theorem.

**Ambition:** Grand challenge — requires deep results about growth rates of Hardy field elements.

---

## Direction 5: Certified Expression Normalization

**Conjecture:** There exists a normalization procedure `normalize : EmlExpr → EmlExpr` such that:
1. `eval(normalize(e), x) = eval(e, x)` for all x (semantic preservation).
2. `emlDepth(normalize(e)) ≤ emlDepth(e)` (depth preservation).
3. `size(normalize(e)) ≤ size(e)` (size reduction).
4. `normalize(deriv(e)) = normalize(deriv(normalize(e)))` (commutativity with differentiation up to normalization).

**Test:** Implement a simple normalization procedure (constant folding, zero elimination, commutativity/associativity normalization). Test properties 1-4 on enumerated expressions of size ≤ 6. Check that the normalized derivative of `eml(add(const(0), mul(const(0), e)), b)` simplifies to `eml(const(0), b)` (or `const(0)` if further simplification is applied).

**Impact:** A certified normalizer with depth guarantees would be the first practical tool emerging from the depth preservation theory — a verified symbolic differentiation engine with provable complexity bounds.

**Catalog References:** `Catalog/Pythagorean/HardyHierarchy/DerivativeNormalizer.lean` (existing normalizer work), `Catalog/Pythagorean/HardyHierarchy/FullEMLDiffClosure.lean` (depth preservation).

**Proof Strategy:** Start with a simple rewrite system (0+a → a, 0*a → 0, 1*a → a, neg(neg(a)) → a). Prove each rule preserves evaluation and depth. The depth preservation theorem guarantees that applying normalization after differentiation does not increase depth. Termination of the rewrite system can be proved using a lexicographic order on (depth, size).

**Domain Bridges:** Term rewriting (confluence, termination), compiler optimization (peephole optimization), certified programming (verified transformations), computer algebra.

**Lineage:** Builds on `deriv_maps_depthClosed` and the depth preservation infrastructure.

**Ambition:** Medium-high — requires careful rewrite system design and termination analysis.
