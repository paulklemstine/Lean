# Summary of changes for run a0eb3d23-3b8a-48be-a44b-fec8ae883d5f
## Completed: Karchmer–Wigderson Games for Closure-Stable Probe Systems

### Files Modified/Created

**1. `Catalog/Bridges/KarchmerWigderson.lean`** — Filled ALL 12 sorries (from 12 → 0):

Key theorems proved (all compile, zero sorry, standard axioms only):

- **`MBoolFormula.toKWProtocol_valid`**: The KW protocol constructed from a monotone formula correctly solves the KW game. For any inputs x, y with F(x)=true, F(y)=false, the protocol outputs a variable i where x(i)=true and y(i)=false.

- **`formula_depth_ge_of_kw_comm_lb`**: Main transfer theorem — if monotone KW communication complexity of f is ≥ b, then every monotone formula computing f has depth ≥ b.

- **`bfsStep_mono` / `bfsIter_mono` / `STConn_monotone`**: Complete monotonicity chain proving that adding edges to a graph preserves st-connectivity.

- **`pathAssignment_connected` / `brokenPath_disconnected`**: Path graphs are connected; removing any edge disconnects them.

- **`unique_separator`**: The path and broken-path assignments differ on exactly one variable.

- **`STConn_kw_comm_lower_bound`** ⭐: Crown jewel — any valid monotone KW protocol for st-connectivity on n vertices has depth ≥ ⌊log₂(n-1)⌋. Proved via injective mapping of n-1 hard pairs to distinct leaf labels.

- **`STConn_formula_depth_lower_bound` / `STConn_circuit_depth_lower_bound`**: Transfer to formula and circuit depth lower bounds.

- **`kw_witness_exists`**: For any monotone Boolean function, positive and negative instances admit a separating variable (by contraposition on monotonicity).

**2. `Catalog/Bridges/KWClosureProbe.lean`** — NEW file (254 lines, 0 sorry):

Bridges closure-stable probe families to Karchmer–Wigderson communication protocols:

- **`kw_witness_exists_general`**: KW witness existence for arbitrary monotone Boolean functions on any type.

- **`closure_probe_separates`**: If a probe family has the separation property w.r.t. a closure operator, it separates non-members from closed sets.

- **`closure_kw_witness`**: The bridge theorem — closure-stable probes with separation yield KW witnesses for opposite-labeled instances.

- **`kw_separator_exists`**: Bundled version using `MonotoneBoolFn` and `KWSeparator` types.

- **`nonmem_witness_from_probes`**: Non-membership in closures is witnessed by separating probes.

- **`iterativeProtocol_depth_le`**: Protocol depth bounded by probe family size (for non-repeating protocols).

- **`reconstructionPotential_le_card`**: Reconstruction potential bounded by candidate set size.

Also fixed: broken import path, incorrect `Prop`-returning definitions needing `Bool`, and an ill-formed `FormulaDepthLowerBoundWitness` (documented with note explaining the specification issue).

**3. `FUTURE_DIRECTIONS.md`** — 5 falsifiable research conjectures extending the work:
1. Exact KW complexity for layered st-connectivity (quadratic bound)
2. Closure operator depth hierarchy via probe rank
3. Quantitative separation strength and potential-based depth bounds
4. Tannaka reconstruction as KW protocol completeness
5. Monotone circuit size lower bounds via probe complexity