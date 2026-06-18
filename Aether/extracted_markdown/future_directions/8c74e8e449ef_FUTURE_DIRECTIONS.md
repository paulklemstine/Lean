# Future Directions: EML Circuit Depth Separation

## Conjecture A: Full Linear Lower Bound for No-EML Expressions with Inverse

**Conjecture:** For any `n ≥ 1` and any `EMLExpr` `e` with `e.noEml` (no `eml` nodes, but possibly with `inv` nodes), `e` cannot represent `iterExp n` on `(0,∞)`.

**Precise statement:** `∀ (e : EMLExpr), e.noEml → ∀ {n : ℕ}, 0 < n → ¬ RepresentsOnPos e (iterExp n)`

**Status:** Proved for the `noInv` subcase (polynomial growth bound argument). The `inv` case remains open because inverse operations produce rational functions whose growth analysis requires tracking both upper and lower bounds through the induction.

**Test:** Enumerate all EML expression trees up to size 15 with `inv` nodes (but no `eml`), evaluate at 100 uniformly-spaced points on `[1, 10]`, and check whether any matches `exp(x)` to within `10⁻⁸` tolerance. If found, verify symbolically. This can be automated in Python with `sympy`.

**Impact:** Closing this gap completes the base case of the depth separation theorem, establishing the full linear lower bound `n ≤ emlDepth(e)` for all `EMLExpr` representations of `iterExp n`.

---

## Conjecture B: Full Linear Lower Bound (emlDepth ≥ n)

**Conjecture:** For every `n ≥ 0`, every `EMLExpr` `e` satisfying `∀ x > 0, e.eval x = iterExp n x` has `e.emlDepth ≥ n`.

**Precise statement:** `∀ (n : ℕ) (e : EMLExpr), RepresentsOnPos e (iterExp n) → n ≤ e.emlDepth`

**Status:** This is the central open theorem. The proof architecture (Strategy A) is in place: `expRank ≤ emlDepth` is proved, and the canonical construction achieves `expRank = emlDepth = n`. What remains is proving the semantic lower bound: any expression computing `iterExp n` must have `expRank ≥ n`.

**Test:** For each `n ∈ {1,2,3,4,5}`, exhaustively generate all `EMLExpr` trees of `emlDepth < n` with constants from `{-1, 0, 1, 2, e}`, evaluate at 50 points in `[0.1, 5]`, and verify no tree matches `iterExp n`. A match would disprove the conjecture.

**Impact:** A full proof would be the first machine-verified lower bound in transcendence-aware circuit complexity, establishing that the EML basis has a strict depth hierarchy for iterated exponentials.

---

## Conjecture C: Logarithmic Lower Bound in the DAG Model

**Conjecture:** If sharing of common subexpressions is allowed (DAG model instead of tree model), the minimum depth for representing `iterExp n` using `eml` gates is `Ω(log n)`.

**Precise statement:** There exists `c > 0` such that for all `n`, every DAG with `eml` gates computing `iterExp n` on `(0,∞)` has depth at least `c · log₂(n+1)`.

**Test:** Implement a DAG representation with hash-consing for common subexpression elimination. For `n ∈ {1,...,20}`, search for minimum-depth DAGs computing `iterExp n` numerically (evaluate at 100 points). Plot depth vs `n` and fit to `c · log n`. If the best achievable depth grows sub-logarithmically, the conjecture is false.

**Impact:** This would extend the depth hierarchy from the tree model to the more powerful DAG model. The gap between `O(log n)` and `Ω(n)` would quantify the power of sharing in EML circuits.

---

## Conjecture D: Growth-Rank Completeness

**Conjecture:** The `expRank` invariant exactly characterizes the eventual growth level of positive EML-definable functions. Specifically, for any `EMLExpr` `e` such that `e.eval` is eventually positive, the function `e.eval` is eventually bounded between `iterExp (expRank(e) - 1)` and `iterExp (expRank(e) + 1)` (in a suitable asymptotic sense).

**Precise statement:** Define `GrowthLevel f k` as `∃ R, ∀ x > R, iterExp (k-1) x ≤ f x ∧ f x ≤ iterExp (k+1) x`. Then for all `e : EMLExpr` with `e.eval` eventually positive, `GrowthLevel (e.eval) (e.expRank)`.

**Test:** Enumerate all EML expressions up to size 10. For each, numerically estimate the growth level by evaluating at `x = 10, 100, 1000` and comparing with `iterExp k` for various `k`. Check whether the estimated growth level matches `expRank`. Mismatches would refute the conjecture.

**Impact:** If true, this establishes `expRank` as a complete invariant for the Hardy-field level of EML-definable functions, connecting circuit complexity to asymptotic differential algebra.

---

## Conjecture E: No Polynomial-Size Compilation from Full to Bounded-Depth EML

**Conjecture:** There is no uniform polynomial-size compilation from `FullExpr` to `EMLExpr` that preserves semantics and keeps `emlDepth` bounded by any fixed constant.

**Precise statement:** For every constant `D` and polynomial `p`, there exists `n` and a `FullExpr` `e` with `e.size ≤ n` such that every `EMLExpr` `e'` with `∀ x > 0, e'.eval x = e.eval x` and `e'.emlDepth ≤ D` satisfies `e'.size > p(n)`.

**Test:** Fix `D = 3`. For `n ∈ {1,...,10}`, take `fullExprIterExp n` (size `n+1`). Search for the smallest `EMLExpr` of `emlDepth ≤ 3` that represents `iterExp n` on a grid. Plot the minimum size vs `n`. If size grows faster than any polynomial, the conjecture is supported.

**Impact:** This would formalize the intuition that bounded-depth EML circuits pay a super-polynomial size penalty for simulating deep exponential nesting, analogous to classical depth-size tradeoffs in Boolean circuit complexity.
