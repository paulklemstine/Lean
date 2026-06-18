# Summary of changes for run ce6d2c38-8b03-4232-8c3e-17a7d7c7d165
## Completed: Size–Depth Tradeoffs for Inverse-Free EML Expressions

### Formally Verified Mathematics (Lean 4)

**`SizeDepthTradeoff.lean`** — A self-contained 639-line Lean 4 file with **45 theorems and 0 sorry**, fully machine-verified. Key results include:

1. **Quantitative majorant theorem** (`noInv_hasPolyTowerMajorant`): Every inverse-free EML expression of depth D is eventually bounded by `iterExp D (C · x^N)` for controlled constants C, N. Proved by structural induction with novel absorption lemmas.

2. **Linear size lower bound** (`size_lower_bound_iterExp`): Any inverse-free expression computing `iterExp n` on positive reals must have syntactic size ≥ n + 1. Bridges the depth hierarchy to a size constraint via `emlDepth_lt_size`.

3. **Depth impossibility** (`iterExp_depth_bounded_impossible`): For n > D, no finite-size depth-D inverse-free expression can compute `iterExp n`. This gives an infinite (stronger than exponential) lower bound.

4. **Shannon counting** (`shannon_counting_impossibility`, `bounded_profiles_card`): Profile counting is polynomial: at most (D+1)(s+1)² profiles at depth D and budget s. No expression of size ≤ n computes iterExp n.

5. **Complete characterization** (`iterExp_size_characterization`): The canonical construction achieves size 2n+1, and no expression of size ≤ n suffices. The minimum size lies in [n+1, 2n+1].

6. **Size unboundedness** (`size_unbounded_at_depth_zero`): At any fixed depth, expression size is unbounded.

Novel definitions: `EMLExpr.size`, `EMLExpr.emlCount`, `GrowthProfile`, `towerMajorant`, `profileBudget`, `boundedProfiles`, `sumOfVars`.

The file also fixes broken imports in the existing catalog files (`Catalog/Algebra/TightDepthHierarchy/Theorems.lean` and `Catalog/Pythagorean/DagDepthHierarchy/Theorems.lean`).

### Other Deliverables

- **`ARTICLE.md`**: A 2000-word popular science article explaining the discovery without technical jargon or references to formal verification tools.

- **`RESEARCH_PAPER.md`**: A comprehensive research paper with abstract, detailed proof sketches, algorithm pseudocode, computational experiments, and discussion of connections to circuit complexity, Kolmogorov complexity, and symbolic regression.

- **`FUTURE_DIRECTIONS.md`**: Five testable scientific hypotheses including tight size characterization (closing the [n+1, 2n+1] gap), extension to full EML with inversions (grand challenge), approximate computation lower bounds, multi-variable extensions, and information-theoretic entropy characterization.

- **`demo.py`**: Working demonstration verifying canonical construction, size lower bounds by enumeration, depth impossibility, profile counting, and conjecture testing.

- **`algorithms.py`**: Implementations of growth profile extraction, expression enumeration, profile counting, and size lower bound verification.

- **`applications.py`**: Applications to symbolic regression hardness, expression compression analysis, and complexity hierarchy visualization.

- **`PACKAGE.json`**: JSON data package bundling all artifacts for web templating.