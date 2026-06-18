# Future Directions

## Synthesis

The tight depth hierarchy theorem (`no_invFree_lowDepth_represents_iterExp`) establishes EML depth as an exact semantic invariant for iterated exponential complexity. This opens a precise complexity theory for analytic expression languages, where the central objects — growth rank, tower majorants, and absorption lemmas — can be extended in multiple directions. The five directions below span from immediate extensions (inverses, size bounds) to paradigm-shifting conjectures (ordinal classification, algebraic independence). All build directly on the polynomial-argument tower majorant technique and the absorption machinery proved in `Speculative/TightDepthHierarchy/Theorems.lean`.

---

## Direction 1: Depth Hierarchy with Controlled Inverses

**Conjecture:** The tight bound *n > D* persists when inverses are allowed only on subexpressions that are bounded away from zero on positive reals. That is, if `e.eval(x) ≥ δ > 0` for all `x > 0`, then `inv(e)` does not increase representational power.

**Test:** Enumerate EML expressions with controlled inverses (where inverse arguments evaluate to ≥ 1 on test points x ∈ {2, 3, 5, 10, 100}) up to depth 3 and size 20. For each, compare numerical evaluation against `iterExp(4, x)` on these test points. If any expression matches within 10⁻¹⁰ relative error, investigate as potential counterexample.

**Impact:** Would extend the tight hierarchy to the most natural class of "well-behaved" expressions, covering nearly all practical symbolic computation.

**Catalog References:** `Speculative/TightDepthHierarchy/Theorems.lean` (main theorem), `Speculative/TightDepthHierarchy/Defs.lean` (noInv predicate).

**Proof Strategy:** Extend `HasPolyTowerMajorant` to handle `inv(e)` when `e.eval(x) ≥ δ`. Since `1/e.eval(x) ≤ 1/δ`, inverse of a bounded-away term adds only a constant, preserving the polynomial tower majorant at the same level.

**Domain Bridges:** Circuit complexity (inverses ↔ negation gates), formal power series (poles vs. analytic functions).

**Lineage:** Direct extension of `no_invFree_lowDepth_represents_iterExp`.

**Ambition:** Solid extension.

---

## Direction 2: Exponential Size Lower Bounds at Fixed Depth

**Conjecture:** For depth *D* and tower height *n ≤ D*, the minimum size of an inverse-free EML expression computing `iterExp(n)` grows at least exponentially in *n/D* (the "compression ratio").

**Test:** For D = 3 and n ∈ {1, 2, 3}, enumerate all inverse-free depth-≤3 expressions up to size 30. Record the minimum size achieving `iterExp(n)` representation (verified on 20 test points to relative error < 10⁻¹²). Plot min-size vs. *n* and test against exponential fit.

**Impact:** Would establish that even when depth suffices, compression comes at exponential size cost — a circuit-complexity-style size-depth tradeoff.

**Catalog References:** `Speculative/TightDepthHierarchy/Defs.lean` (EMLExpr.size), `Speculative/TightDepthHierarchy/Theorems.lean` (separation machinery).

**Proof Strategy:** Count the number of distinct growth profiles achievable by size-*s* depth-*D* expressions. Show this count is polynomial in *s* but the precision needed to match `iterExp(n)` grows super-polynomially.

**Domain Bridges:** Shannon's counting argument (circuit complexity), Kolmogorov complexity.

**Lineage:** Builds on `noInv_hasPolyTowerMajorant` (growth classification).

**Ambition:** Solid extension.

---

## Direction 3: DAG Sharing Does Not Reduce Depth (Grand Challenge)

**Conjecture:** Even when subexpression sharing (DAG representation) is allowed, the minimum depth required to compute `iterExp(n)` remains *n* for inverse-free expressions.

**Test:** Implement a bounded search over EML DAGs (expressions where subexpressions can be referenced multiple times) up to depth 4 and 15 nodes. For each DAG, evaluate on test points and compare with `iterExp(5, x)`. Report any DAG of depth < 5 that matches.

**Impact:** Would show that the depth hierarchy is robust under the most powerful structural optimization — sharing. This would parallel the result that AC⁰ lower bounds hold even for non-uniform circuits.

**Catalog References:** `Speculative/TightDepthHierarchy/Theorems.lean` (tree-based separation).

**Proof Strategy:** Show that unfolding a depth-*D* DAG into a tree does not increase `emlDepth` beyond *D*. Then the tree-based theorem applies directly.

**Domain Bridges:** DAG-based circuit complexity, common subexpression elimination (compilers).

**Lineage:** Direct extension of `depth_hierarchy_for_iterExp_family`.

**Ambition:** Grand challenge — requires formalizing DAG semantics and proving structural equivalence.

---

## Direction 4: Growth Rank Completeness (Grand Challenge)

**Conjecture:** For every inverse-free EML expression *e*, the growth rank `growthRank(e)` equals the exact tower majorant level — i.e., `HasPolyTowerMajorant(k, e)` holds for `k = growthRank(e)` but NOT for `k = growthRank(e) - 1` (when `growthRank(e) ≥ 1`).

**Test:** Enumerate inverse-free expressions up to size 10. For each, numerically estimate the tower majorant level by evaluating at x ∈ {10, 100, 1000} and fitting against `iterExp(k, ·)` for k = 0, 1, 2, 3. Verify that the fitted level matches `growthRank(e)` and that no lower level suffices (the expression exceeds `iterExp(k-1, C·x^N)` for all reasonable C, N).

**Impact:** Would establish `growthRank` as a complete semantic invariant, not just an upper bound. This would create a full classification theory for EML expression complexity.

**Catalog References:** `Speculative/TightDepthHierarchy/Defs.lean` (growthRank definition), `Speculative/TightDepthHierarchy/Theorems.lean` (growthRank_le_emlDepth).

**Proof Strategy:** For the lower bound direction, show that `eml(const 1, e)` when `e` has growth rank *k* produces a function that exceeds `iterExp(k, C·x^N)` for any fixed C, N. Use MVT or derivative growth analysis.

**Domain Bridges:** Fast-growing hierarchy (ordinal classification), descriptive complexity (Immerman-Szelepcsényi for function classes).

**Lineage:** Extends `growthRank_le_emlDepth` to an equality characterization.

**Ambition:** Grand challenge — requires lower bounds on growth, not just upper bounds.

---

## Direction 5: Ordinal Classification of EML Growth

**Conjecture:** There exists a natural assignment of ordinals to EML expressions such that the growth rate of `e.eval` is precisely characterized by its ordinal rank, with `iterExp(n)` corresponding to ordinal ω·n in the fast-growing hierarchy.

**Test:** Implement the fast-growing hierarchy F_α for α < ω² in Python. For EML expressions of depth ≤ 3, numerically compare growth rates with F_α for various α. Verify that depth-*D* expressions with *k* eml-nestings match F_{ω·k} up to polynomial factors.

**Impact:** Would establish a deep connection between EML syntax and proof-theoretic ordinal analysis, potentially linking expression complexity to proof strength.

**Catalog References:** `Speculative/TightDepthHierarchy/Theorems.lean` (iterExp hierarchy), `Catalog/Speculative/HardyHierarchy/` (if present).

**Proof Strategy:** Define the ordinal assignment compositionally: algebraic operations preserve ordinal level, `eml` increments by ω. Prove that this assignment is compatible with the fast-growing hierarchy classification.

**Domain Bridges:** Proof theory (ordinal analysis), reverse mathematics, independence results.

**Lineage:** Natural continuation of the depth hierarchy.

**Ambition:** Grand challenge — requires bridging analytic function theory with ordinal combinatorics.
