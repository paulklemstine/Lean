# Summary of changes for run 402ab086-a922-4015-b67d-3e1a41ca2055
Delivered a new, fully-proved Lean 4 development plus the required research artifacts, in the requested Lean-only (Phase A) form.

**New file:** `Catalog/Bridges/BerggrenBoundaryHeight.lean` — "Arithmetic-Height Monotonicity for Finite Berggren Subtrees." It builds directly on the catalog: it imports and reuses `BerggrenGen`/`BerggrenWord`/`prefixClosed`/`boundaryWords` from `Bridges/BerggrenTransferDuality.lean` and `ratArithHeight`/`ratArithHeight_ge_one` from `Bridges/ArithmeticVCDimension.lean`, turning arithmetic height from a pointwise triple statistic into a monotone boundary functional on finite prefix-closed Berggren subtrees.

**Main theorems (all proved; sorry = 0; only standard axioms `propext`/`Classical.choice`/`Quot.sound`):**
- `boundaryHeightF_ge_card` and `boundaryHeightF_ge_card_mul_min` — boundary-height nonnegativity / lower bounds by leaf cardinality and by cardinality × minimum height.
- `boundaryF_expand` — the exact combinatorial description of the boundary after a one-step ternary Berggren leaf expansion (the structural core).
- `boundaryHeightF_expand_eq` — a subtraction-free additive accounting identity.
- `boundaryHeightF_expand_mono` and `boundaryHeightF_expand_strict` — weak and strict one-step expansion monotonicity under explicit local growth hypotheses (`ChildrenDominate` / `ChildrenDominateStrict`).
- `coe_boundaryF` — a bridge proving the new `Finset`-level boundary coincides with the catalog's `Set`-level `boundaryWords`.
- `wordArithHeight` (concrete pullback of `ratArithHeight` along word evaluation from root `(3,4,5)`) with `boundaryHeightF_wordArithHeight_ge_card`, an unconditional certified arithmetic-complexity lower bound read off boundary structure.

**Adversarial finding (documented):** expansion monotonicity is provably false without a growth hypothesis (the accounting identity removes the parent height and adds the three child heights), so the growth hypothesis is the exact boundary condition; computation shows the concrete `wordArithHeight` satisfies even strict per-child domination on all tested words, motivating a conjecture.

**Other deliverables:** brief `-- !--` proof-sketch comments on each theorem, a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis), and `FUTURE_DIRECTIONS.md` with 5 falsifiable conjectures, each containing a "The key insight is..." sentence and a "Why now?" justification.

**Build note:** the outer `lakefile.toml` pointed at source paths that did not exist (sources live under `Catalog/`); I added `srcDir = "Catalog"` so the project compiles. The whole module builds cleanly via `lake build Bridges.BerggrenBoundaryHeight` with no sorries.