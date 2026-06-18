# Summary of changes for run 3903a7ab-c6da-41c7-8589-4e6a606691a2
## Completed: Undecidability Thresholds in Min-Plus Arithmetic

### Key Mathematical Discovery

During the analysis, I discovered a crucial mathematical insight: the fragment proposed in the prompt (existential satisfiability of min-plus formulas with min, +, constants, equations and inequalities over ℤ, *without* multiplication) is actually **decidable**, not undecidable — because it embeds into existential Presburger arithmetic (min(a,b) is definable in Presburger). This means the originally proposed theorem would have been false.

Instead, I identified the **correct undecidability threshold**: **multiplication** is the exact operation that crosses the line from decidability to undecidability. Without multiplication, tropical satisfiability reduces to integer linear feasibility (decidable). With multiplication, it encodes Diophantine equations (undecidable by DPRM).

### Formally Verified Lean 4 Proofs (100% sorry-free)

**File: `Catalog/Tropical/Undecidability/Defs.lean`** (~200 lines)
- `TropTerm` — terms with var, const, add, min, mul
- `TropAtom` — atomic formulas (eq, le)
- `TropExistsCNF` — existential conjunctive formulas with satisfiability predicate
- `IntExpr` — integer polynomial expressions with evaluation
- `IntExpr.toTropTerm` — faithful embedding of polynomials into tropical terms
- `IntExpr.toTropTerm_eval` — embedding preserves evaluation exactly
- `poly_system_iff_tropical` — **Reduction theorem**: polynomial satisfiability ↔ tropical satisfiability
- Distributivity: `eval_add_tmin_left`, `eval_add_tmin_right`

**File: `Catalog/Tropical/Undecidability/Threshold.lean`** (~220 lines)
- `tropical_undecidable_of_dioph_undecidable` — **Conditional undecidability transfer**: if Diophantine satisfiability is undecidable, then tropical satisfiability with mul is undecidable
- `mul_free_eval_midpoint_concavity` — **Structural theorem**: mul-free terms satisfy discrete midpoint concavity f(n+1) + f(n-1) ≤ 2·f(n), proved by induction with a key case analysis for the min operation
- `mul_free_cannot_express_square` — **Separation theorem**: no mul-free term can represent x² (by contradiction from concavity violation at n=0)
- `tropical_threshold` — **The main threshold theorem** combining all three results
- `TwoCounterMachine` — Complete two-counter machine model with Step, Steps, Halts
- Concrete examples: `trop_x_sq_minus_one_sat`, `trop_x_sq_plus_one_unsat`, `mul_equation_xy_eq_6_sat`, `sum_of_squares_plus_one_unsat`
- Machine examples: `trivialMachine_halts`, `incOnce_halts`

All proofs verified with `lake build`, using only standard axioms (propext, Classical.choice, Quot.sound).

### Other Deliverables

- **ARTICLE.md** — Popular science article (~2500 words) explaining the threshold discovery
- **RESEARCH_PAPER.md** — Full research paper with abstract, definitions, theorem statements, proof sketches, applications, and references
- **FUTURE_DIRECTIONS.md** — Five breakthrough-level research directions: (1) Tropical Matiyasevich program, (2) Decidability classification for restricted fragments, (3) Matrix reachability, (4) Complexity-theoretic completeness, (5) Tropical interpretability and logic transfer
- **demo.py** — Interactive demonstrations of tropical evaluation, polynomial encoding, midpoint concavity, and two-counter machines
- **algorithms.py** — Min-of-affine normal form computation, mul-free satisfiability checker, polynomial-to-tropical encoder, TCM analyzer
- **applications.py** — Shortest-path verification, scheduling, ReLU neural network analysis
- **visualizations.py** — SVG charts for concavity comparison, threshold diagram, piecewise-linear vs polynomial
- **PACKAGE.json** — Complete JSON bundle of all artifacts