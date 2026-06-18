# Summary of changes for run caa5e837-2795-468d-a8b5-16366d22fe29
## Completed: M-Convex Support Shadow Compression Beyond Matroids

### Key Mathematical Discovery

I investigated whether the matroid basis shadow bound C(ω, k) extends to all M-convex supports. **The naive conjecture is false**: the full simplex of all degree-4 vectors on 3 variables is M-convex with ω=3, but its degree-2 shadow has 6 elements > C(3,2)=3. The multiaffine constraint (all coordinates ≤ 1) is essential for the binomial bound. This identifies the true mechanism: support compression is a theorem of exchange geometry **combined with** multiaffinity, not exchange geometry alone.

### Formally Verified Mathematics (Lean 4)

**File: `Pythagorean/MConvexShadowCompression.lean`** — 0 sorries, all standard axioms (propext, Classical.choice, Quot.sound). Contains:

**New definitions:**
- `totalDeg`, `activeCoords`, `IsMConvexExchangeFinset`, `IsMultiaffine`
- `degreeShadowSet` (degree-k shadow), `quadraticLeafSet` (d-2 shadow)
- `tropicalDot`, `initialSupportSet` (tropical weight minimizers)
- `ShadowHereditaryExchange` (shadow exchange property)

**Proved theorems (all sorry-free):**
1. `mem_degreeShadow_support_subset` — Shadow elements have support ⊆ activeCoords
2. `mem_degreeShadow_degree` — Shadow elements have the correct total degree
3. `degreeShadow_zero_outside_active` — **Contradiction proof**: inactive coordinates force zero values
4. `degreeShadowSet_finite` — Degree shadows are finite sets
5. `multiaffine_le_multiaffine` — Multiaffinity is inherited by dominated elements
6. `multiaffine_shadow_injection` — Shadow elements biject with support subsets (multiaffine case)
7. `degreeShadow_card_le_of_multiaffine` — **Main theorem**: |shadow_k| ≤ C(ω, k) for multiaffine families (injection + rcases proof using exchange witnesses)
8. `quadraticLeaf_card_le_of_multiaffine` — Corollary: quadratic leaf bound C(ω, d-2)
9. `initialSupportSet_nonempty` — Tropical initial supports are nonempty
10. `initialSupportSet_subset` — Initial supports ⊆ original support
11. `tropical_exchange_equal_weight` — **Tropical bridge theorem**: M-convex exchanges with w(i)=w(j) preserve tropical weight
12. Plus auxiliary lemmas: `mem_activeCoords_iff`, `activeCoords_empty`, `mconvex_singleton`, `mconvex_empty`, `support_subset_of_le`

### Other Deliverables

- **`ARTICLE.md`** — Popular science article (~2000 words) explaining the mathematics accessibly, with no mention of formal verification tools
- **`RESEARCH_PAPER.md`** — Technical research paper with abstract, proofs, algorithms, counterexample table, and references
- **`FUTURE_DIRECTIONS.md`** — 5 research directions with structured format (Conjecture/Test/Impact/etc.), including 2 grand challenges (shadow M-convexity, Lorentzian positivity tightening)
- **`demo.py`** — Working demo: constructs M-convex supports (uniform matroids, Schur polynomials, full simplices, polymatroids), computes shadows, verifies/falsifies bounds
- **`algorithms.py`** — Full algorithm implementations with docstrings and complexity analysis
- **`applications.py`** — Applications: Hessian certification, Newton polytope analysis, tropical face enumeration, matroid independence counting
- **`viz_shadow_profile.py`**, **`viz_exchange_graph.py`**, **`viz_tropical.py`** — Matplotlib visualizations
- **`interactive_exchange.html`**, **`interactive_shadow.html`** — Interactive HTML demos
- **`PACKAGE.json`** — Complete JSON data package bundling all artifacts