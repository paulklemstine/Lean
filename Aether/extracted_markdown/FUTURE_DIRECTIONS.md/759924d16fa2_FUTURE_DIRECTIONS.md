# Future Directions: Differential Closure and Transseries Fragments

## Synthesis

The differential closure principle established in `Speculative/HardyHierarchy/DiffClosure.lean` opens a concrete path from static growth hierarchies to certified differential calculus over transseries-like fragments. The five directions below form a coherent program: **Conjectures A and B** probe the sharpness and optimality of the depth bound, guiding whether a normalizer (Conjecture D) can improve it. **Conjecture C** extends closure to quotients, which is the missing ingredient for full differential field structure. **Conjecture E** aims at the grand challenge of connecting formal Hardy-level classification to classical asymptotic series manipulation.

Each conjecture builds on the catalog theorems in `Speculative/HardyHierarchy/Theorems.lean` (especially `hardyLevel_closed_under_eml` and `emlDepth_le_hardyLevel`) and the new results in `Speculative/HardyHierarchy/DiffClosure.lean`.

---

## Direction 1: Sharpness of the +1 Depth Bound

**Conjecture:** There exists an infinite family of eventually positive PosEMLExpr expressions `e_n` of depth `n` such that `depth(deriv(e_n)) = n + 1` exactly, not merely `≤ n + 1`.

**Test:** Enumerate all PosEMLExpr up to depth 5 and compute symbolic derivatives. For each depth level, record the maximum achieved `depth(deriv(e)) - depth(e)`. If the gap is always 0 (as observed for `exp(x)`, `exp(exp(x))`, etc.), the +1 bound is loose and could be tightened to +0. Conversely, finding any expression where the gap equals +1 confirms sharpness at that depth.

**Impact:** If the bound is not sharp (gap always 0), the differential closure theorem can be strengthened to `depth(deriv(e)) ≤ depth(e)`, which would mean differentiation *never* increases Hardy level — a dramatically stronger result with implications for transseries stability.

**Catalog References:**
- `Speculative/HardyHierarchy/DiffClosure.lean`: `depth_deriv_le`, `depth_deriv_exp_var`
- `Speculative/HardyHierarchy/Theorems.lean`: `emlDepth_le_hardyLevel`

**Proof Strategy:** For sharpness, construct explicit expressions where the product rule forces depth increase. The candidate is an expression like `mul (exp (exp x)) (exp (exp x))` where the product rule creates `add (mul (deriv ...) ...) (mul (...) (deriv ...))` with depth potentially exceeding the original. For non-sharpness, prove by induction that the `mul` case always stays within `depth(e)`.

**Domain Bridges:** Symbolic computation (simplification strategies), asymptotic analysis (whether differentiation changes the "order" of an asymptotic expansion)

**Lineage:** Extends `depth_deriv_le` from the current development

**Ambition:** ★★★ (Solid extension — directly testable, likely resolvable within one research cycle)

---

## Direction 2: Logarithmic Derivative Level Bound for Pure Exponentials

**Conjecture:** If `e = exp(b)` with `b` a PosEMLExpr of depth `d` and `e` eventually positive, then `logDeriv(eval e)` has Hardy level at most `d`, not `d + 1`.

**Test:** For PosEMLExpr `b` up to depth 4, compute `logDeriv(exp(b)) = b'` and compare the Hardy depth of `b'` to `d` and `d + 1`. Since `logDeriv(exp(b)) = b'`, the question reduces to whether `depth(deriv(b)) ≤ depth(b)` for all `b`.

**Impact:** Would establish that logarithmic differentiation of pure exponentials is "free" in terms of Hardy level — a key structural property for WKB approximation where one works with `log(y)` rather than `y` directly. This connects to the observation that WKB series do not increase in transcendence complexity.

**Catalog References:**
- `Speculative/HardyHierarchy/DiffClosure.lean`: `logDeriv_mul_exp`, `depth_deriv_le`
- `Speculative/HardyHierarchy/Theorems.lean`: `hardyLevel_closed_under_eml`

**Proof Strategy:** Reduce to showing `depth(deriv(b)) ≤ depth(b)` for arbitrary `b`. This would follow if the +1 bound in `depth_deriv_le` can be tightened to +0 (see Conjecture A). If that fails, prove it for restricted fragments (e.g., when `b` contains no `mul` nodes).

**Domain Bridges:** WKB approximation, steepest descent analysis, Riccati equation theory

**Lineage:** Extends `logDeriv_mul_exp` from the current development

**Ambition:** ★★★ (Solid extension — equivalent to Conjecture A for the exponential case)

---

## Direction 3: Differential Closure Under Quotients

**Conjecture:** If `a, b` are eventually positive PosEMLExpr expressions of depth at most `d` with `b(x) ≠ 0` for sufficiently large `x`, then `deriv(a/b)` has Hardy level at most `d + 1`.

**Test:** Extend PosEMLExpr with a `div` constructor (or represent `a/b` externally). Enumerate pairs `(a, b)` up to depth 3, compute the quotient rule derivative `(a'b - ab')/b²`, and check whether the resulting expression can be bounded at Hardy level `d + 1`. Look for violations by computing numerical values at large `x` and comparing growth rates.

**Impact:** This is the critical missing piece for full differential field structure. Hardy fields are closed under quotients, and proving this formally would upgrade `DiffClosedFragment` from a differential ring to a differential field — a prerequisite for connecting to Aschenbrenner-van den Dries-van der Hoeven's work on transseries.

**Catalog References:**
- `Speculative/HardyHierarchy/DiffClosure.lean`: `DiffClosedFragment`, `hardyLevel_deriv_le_succ`
- `Speculative/HardyHierarchy/Theorems.lean`: `hardyLevel_closed_under_eml`, `hardyLevel_mono`

**Proof Strategy:** The quotient rule gives `(a'b - ab')/b²`. The numerator is at Hardy level ≤ `d + 1` (by closure under addition, multiplication, and the derivative bound). The denominator `b²` is at level `d`. The key challenge: prove that division by a level-`d` function does not increase level. This requires either extending `HardyLevel` with a division constructor or proving a semantic domination argument.

**Domain Bridges:** Differential algebra (differential field structure), Padé approximation, asymptotic expansion of rational functions

**Lineage:** Extends both `hardyLevel_deriv_le_succ` and `hardyLevel_closed_under_eml`

**Ambition:** ★★★★ (Grand challenge — requires significant new infrastructure)

---

## Direction 4: Normalizing Derivative Compiler with Improved Bounds

**Conjecture:** There exists a normalizer `normalize : PosEMLExpr → PosEMLExpr` preserving evaluation semantics such that `depth(normalize(deriv(e))) ≤ depth(e)` for all eventually positive `e` in a restricted fragment (e.g., no nested `mul` inside `exp`).

**Test:** Implement candidate normalizers:
1. Constant folding: `const(0) * e ↦ const(0)`, `const(1) * e ↦ e`
2. Exp consolidation: `mul (deriv a) (exp a) ↦ exp(add a (log (deriv a)))` (requires `log`)
3. Depth-reducing rewrites: identify patterns where simplification reduces `exp` nesting

Run on exhaustive enumeration up to depth 4 and measure the gap between `depth(normalize(deriv(e)))` and `depth(e)`. If the gap is consistently ≤ 0 for a well-defined fragment, the conjecture holds.

**Impact:** A normalizing compiler would turn the theoretical +1 bound into a practical 0 bound after simplification, meaning the Hardy hierarchy is truly stable under differentiation in practice. This has direct implications for certified computer algebra systems.

**Catalog References:**
- `Speculative/HardyHierarchy/DiffClosure.lean`: `PosEMLExpr.deriv`, `depth_deriv_le`

**Proof Strategy:** Define `normalize` by structural recursion with rewrite rules. Prove `eval (normalize e) = eval e` by induction (semantic correctness). Then prove `depth (normalize (deriv e)) ≤ depth e` for a restricted fragment by case analysis on the structure of `deriv e` after normalization.

**Domain Bridges:** Computer algebra (canonical forms), compiler optimization (expression simplification), symbolic computation

**Lineage:** Extends `PosEMLExpr.deriv` and `depth_deriv_le`

**Ambition:** ★★★ (Solid extension — feasible with careful fragment selection)

---

## Direction 5: Full Transseries Truncation Theory

**Conjecture:** The `DiffClosedFragment` structure can be extended to a `TransseriesFragment` that includes:
1. A well-ordering on monomials
2. Truncation operators `trunc_n : Expr → Expr` that discard terms above Hardy level `n`
3. A certified asymptotic expansion theorem: `eval(trunc_n(e))` is an asymptotic approximation to `eval(e)` with error bounded by level-`(n+1)` terms
4. Compatibility of truncation with differentiation: `trunc_n(deriv(e)) =ᶠ deriv(trunc_n(e))` up to asymptotically negligible terms

**Test:** For concrete expressions like `x + exp(x) + exp(exp(x))`:
1. Truncate at level 0: keep `x`, discard exponentials
2. Truncate at level 1: keep `x + exp(x)`, discard double exponentials
3. Verify numerically that the truncation error has the predicted growth rate
4. Verify that differentiating before/after truncation gives asymptotically equivalent results

**Impact:** This would be the first machine-checked theory of transseries truncation, connecting formal Hardy hierarchies to the practical toolbox of asymptotic analysis used in applied mathematics and physics. It would bridge the gap between Écalle's formal theory and computable asymptotic methods.

**Catalog References:**
- `Speculative/HardyHierarchy/DiffClosure.lean`: `DiffClosedFragment`, `posEMLFragment`
- `Speculative/HardyHierarchy/Theorems.lean`: `hardyLevel_zero_poly_bound`, `exp_not_hardyLevel_zero`

**Proof Strategy:** Define truncation as a syntactic operation that replaces sub-expressions above a given depth with `const 0`. Prove that:
1. Truncation reduces depth: `depth(trunc_n(e)) ≤ n`
2. Truncation error is eventually dominated by a level-`(n+1)` function (using `hardyLevel_zero_poly_bound` and hierarchy separation)
3. Truncation commutes with differentiation up to asymptotically negligible terms

The separation theorem `exp_not_hardyLevel_zero` provides the base case for bounding truncation errors.

**Domain Bridges:** Transseries theory (Écalle, Aschenbrenner-van den Dries-van der Hoeven), asymptotic analysis (matched asymptotics, WKB), mathematical physics (renormalization, resurgence), computer algebra (asymptotic simplification)

**Lineage:** Grand challenge extending all results in the current development

**Ambition:** ★★★★★ (Paradigm-shifting — would establish the first formal foundation for machine-checked transseries)
