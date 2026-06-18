# Summary of changes for run 3c392310-e094-4acc-9e40-8e45d1dc36a5
## Completed: Depth Preservation for Full EML with Negation

### Deliverable 1 — Formally Verified Mathematics (Lean 4)

**File:** `Catalog/Pythagorean/HardyHierarchy/FullEMLDiffClosure.lean` (276 lines, zero `sorry`, standard axioms only)

Defines `EmlExpr.deriv` on the full EML grammar (including negation) and proves 6 substantive theorems:

1. **`EmlExpr.depth_deriv_le_self`** — Main theorem: `emlDepth(deriv(e)) ≤ emlDepth(e)` for all expressions. Proved by structural induction with careful handling of the `eml(a,b)` case, where the derivative `eml(a' + a·b', b)` preserves the exponential shell.

2. **`EmlExpr.depth_iteratedDeriv_le_self`** — Iterated stability: `emlDepth(deriv^[n](e)) ≤ emlDepth(e)` for all n. Makes depth a certified differential invariant.

3. **`EmlExpr.differentiallyDepthBounded_iff`** — Characterization: `DifferentiallyDepthBounded k e ↔ emlDepth e ≤ k`. One need not check infinitely many derivatives — the expression itself determines membership.

4. **`EmlExpr.deriv_maps_depthClosed`** — Set-theoretic closure: `deriv` maps `{e | emlDepth e ≤ k}` into itself.

5. **`EmlExpr.eval_hasDerivAt`** — Semantic correctness: symbolic derivative agrees with the analytic derivative at every point (via `HasDerivAt`).

6. **`EmlExpr.depth_neg_deriv`** — Negation transparency: `emlDepth(deriv(neg e)) = emlDepth(deriv e)`.

All proofs use real tactics (structural induction, omega, ring, simp, calc-style reasoning). Verified with `#print axioms` — only `propext`, `Classical.choice`, `Quot.sound`.

### Deliverable 2 — Popular Science Article
**File:** `ARTICLE.md` (~2500 words)

### Deliverable 3 — Research Paper
**File:** `RESEARCH_PAPER.md` (~5000 words, with theorems, proofs, algorithms, computational experiments, and references)

### Deliverable 4 — Python Code
- **`demo.py`** — Interactive demo: basic examples, systematic enumeration of 654 expressions, depth verification, numerical evaluation sanity checks
- **`algorithms.py`** — Core algorithms with complexity analysis: enumeration, depth checker, size growth analysis, depth classification
- **`applications.py`** — Four applications: certified CAS differentiation, depth-aware compilation, AD resource bounds, Hardy field classification

### Deliverable 5 — Future Directions
**File:** `FUTURE_DIRECTIONS.md` — 5 directions including 2 grand challenges (logarithmic extension, transseries connection) and 3 solid extensions (exact preservation classification, size growth bounds, certified normalization)

### Deliverable 6 — JSON Data Package
**File:** `PACKAGE.json` — Valid JSON bundling all content for web templating