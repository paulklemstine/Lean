# Summary of changes for run 342a1d39-76d1-4881-ba77-8a5a88f8a1aa
Delivered a new, fully-proved Lean 4 file plus the required research notes, building a cross-domain bridge inside the Bridges catalog.

## New file: `Bridges/ArithmeticBoundaryMonotonicity.lean`
Fuses the combinatorial Berggren boundary framework of `Bridges/BerggrenTransferDuality.lean` (`prefixClosed`, `finiteBerggrenSubtree`, `boundaryWords`, `prefixClosed_take_mem`, `boundaryWords_finite`, `exists_max_depth`) with the arithmetic-height API of `Bridges/ArithmeticVCDimension.lean` (`ArithmeticVCDim.ratArithHeight`). It pushes each Berggren word to its Pythagorean transfer state via `evalWord` (the (3,4,5)-rooted iteration of the three Berggren generators, matching the catalog `childA/B/C` / `actGen`) and measures the coordinatewise rational arithmetic height `triHeight`.

Main theorems (all proved, `sorry`-free, only standard axioms `propext`/`Classical.choice`/`Quot.sound`):
- `evalWord_good` — the order invariant `0<a, 0<b, a<c, b<c` is preserved by all three generators.
- `evalWord_pythagorean` — transfer states stay on the light cone `a²+b²=c²`.
- `triHeight_eq` — closed form `a+b+c+3` on the positive cone.
- `triHeight_step_lb` — additive monotonicity `triHeight w + 10 ≤ triHeight (w ++ [g])` (an explicit additive lower bound, strictly stronger than mere non-decrease).
- `triHeight_lt_extend`, `triHeight_mono_append` — strict / weak monotonicity along extensions.
- `triHeight_linear_lb` — `15 + 10·|w| ≤ triHeight w` (height certifies depth).
- `boundary_mem_prefixes_extend`, `boundaryWords_nonempty` — boundary structure.
- `exists_min_height_boundary` — transfer-selection theorem: every finite Berggren subtree has a canonical minimal-height boundary representative.

Key finding: monotonicity holds strictly and uniformly (+10/step) and needs only the order invariant — Pythagoreanness rides along for free. Numeric sanity confirmed (height 15 at the root, 33 after one step).

The file also contains the requested artifacts: a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and `-- !-- ... -- !--` proof-sketch blocks for the main theorems.

## `Bridges/FUTURE_DIRECTIONS.md`
Freeform narrative with a synthesis, results summary, and 5 falsifiable research directions (sharp per-generator step spectrum; height-stratified Northcott counting; transfer to the reduced leg-ratio height; two-sided height control + reconstruction; Lyapunov/failure boundary under inverse generators), each with a "The key insight is…" sentence and a "Why now?" justification.

Verification: `lake build` of `Bridges.ArithmeticBoundaryMonotonicity` succeeds, no `sorry` remains, and `#print axioms` shows only standard axioms. No forbidden deliverables were produced.