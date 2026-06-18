# Summary of changes for run 7a73b6d8-5538-4faf-a845-12b06bc5735b
## Codomain-Constrained Stone–Weierstrass via Metric Projection

### Formally Verified Mathematics (Lean 4)

Two fully proven Lean files with **zero `sorry`** and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

**`EML/ConvexRetraction.lean`** (152 lines) — Metric projection onto compact convex sets:
- `MetricProjection.exists_unique_nearest`: For any nonempty compact convex set C in a real inner product space, every point has a unique nearest point in C. Proved via the parallelogram identity and convexity.
- `MetricProjection.proj`: The metric projection function, defined as the unique nearest-point map.
- `MetricProjection.lipschitzWith_one`: **The projection is 1-Lipschitz (nonexpansive).** This is the pivotal geometric fact — proved via the variational characterization of nearest points and inner product inequalities.
- `MetricProjection.proj_self`: The projection fixes points already in C.
- `exists_continuous_retraction_compact_convex`: **Main retraction theorem** — packages all properties into a single existential: there exists r : E → E that is continuous, maps everything into C, fixes C, and is 1-Lipschitz.

**`EML/ConvexStoneWeierstrass.lean`** (98 lines) — Codomain-constrained approximation:
- `eml_dense_compact_convex`: **The main theorem.** Given f : K → E with f(K) ⊆ C and any ambient approximant G with dist(f, G) < ε, the composition g = π_C ∘ G satisfies g(K) ⊆ C and dist(f, g) < ε. The proof is three lines: g maps into C by projection, and the error bound follows from 1-Lipschitz + fixed-point property.
- `eml_dense_compact_convex_finite_dim`: Finite-dimensional specialization with subalgebra hypothesis.
- `isClosed_continuousMapsInto`: The set of continuous maps into a compact set is closed.

### Python Demonstrations (`demos/`)

**`demos/convex_retraction_demo.py`** — Core visualizations:
- Metric projection flow fields onto triangles and ellipses
- The 1-Lipschitz contraction property demonstrated empirically
- Side-by-side comparison: target curve in C, unconstrained approximant leaving C, and projected approximant staying in C with better error

**`demos/applications_demo.py`** — Real-world applications:
- **Stochastic kernel approximation**: Polynomial approximation of probability distributions, projected onto the simplex to ensure valid probabilities
- **Safe reinforcement learning**: Box-constrained control signals with clamping projection
- **Portfolio optimization**: Weight allocations constrained to the simplex with per-asset bounds
- **Convergence analysis**: Systematic comparison showing projection never worsens error across polynomial degrees

All demos produce figures in `demos/figures/` (7 PNG visualizations).

### Research Paper (`paper/convex_stone_weierstrass.md`)

A complete mathematical paper covering:
- The metric projection theory (existence, uniqueness, 1-Lipschitz)
- The codomain-constrained approximation theorem with full proof
- Connection to Stone–Weierstrass and subalgebra approximation
- Formal verification methodology and axiom audit
- Applications to probability, control, finance, and ML
- A Scientific American–style discussion section explaining the "snap-back" intuition
- Future directions including non-convex codomains and tropical extensions

### Key Mathematical Insight

The entire development rests on one beautiful inequality: **the metric projection onto a compact convex set is 1-Lipschitz**. This single fact means that composing any approximant with the projection can only improve the approximation error, while guaranteeing the output stays in the constraint set. The proof of the main theorem is essentially:

1. Given f : K → C and G : K → E with ‖f - G‖ < ε
2. Define g = π_C ∘ G (project G onto C)
3. Then g(K) ⊆ C, and ‖f - g‖ = ‖π_C(f) - π_C(G)‖ ≤ ‖f - G‖ < ε ∎