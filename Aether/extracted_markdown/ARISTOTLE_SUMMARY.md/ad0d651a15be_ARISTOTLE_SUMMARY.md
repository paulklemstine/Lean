# Summary of changes for run 22cdc553-0967-4f98-b7ac-8d3a17f13b92
Added a new, fully compiling, sorry-free Lean development on the **set-local distortion of Hausdorff dimension**, plus a research roadmap.

**New file:** `Geometry/FractalDimension.lean` (builds cleanly; verified with `#print axioms` to depend only on `propext`, `Classical.choice`, `Quot.sound`).

Mathlib previously had only the *global* theory (e.g. `Isometry.dimH_image`, `AntilipschitzWith.le_dimH_image`). This file builds the *set-local* theory — the realistic setting for fractals, IFS attractors and quasi-symmetric maps where good metric control holds only on a subset. Main results (all proved, no `sorry`):

1. `le_dimH_image_of_lipschitzOn_leftInverse` — a left inverse that is Lipschitz on `f '' s` forces `dimH s ≤ dimH (f '' s)`.
2. `dimH_image_eq_of_lipschitzOn_lipschitzOn_inverse` — set-local bi-Lipschitz invariance: `dimH (f '' s) = dimH s`.
3. `dimH_image_bounds_of_holderOn_holderOn_inverse` — the best theorem: a two-sided Hölder ("quasi-symmetric flavour") squeeze `dimH (f '' s) ≤ dimH s / rf` and `dimH s ≤ dimH (f '' s) / rg`, interpolating between the Lipschitz (`r = 1`, exact invariance) and general Hölder regimes.
4. A new `AntilipschitzOnWith` predicate (set-local analogue of Mathlib's `AntilipschitzWith`), with `AntilipschitzOnWith.injOn`, `AntilipschitzOnWith.lipschitzOnWith_invFunOn`, the lower bound `AntilipschitzOnWith.le_dimH_image`, and the intrinsic invariance corollary `dimH_image_eq_of_lipschitzOn_antilipschitzOn`.
A sanity `example` recovers the identity case.

Each theorem carries a one–two sentence proof sketch in `-- !-- ... -- !--` comment blocks. The development is built on Mathlib's `HolderOnWith.dimH_image_le` / `LipschitzOnWith.dimH_image_le` and `InjOn.leftInvOn_invFunOn`, generalizing Mathlib's global isometry-invariance results to arbitrary subsets.

**Research roadmap:** `Geometry/FUTURE_DIRECTIONS.md` gives five falsifiable conjectures (quasi-symmetric distortion via the modulus η — noting the naïve dimension bound is actually false; conformal dimension as a quasi-symmetric invariant; IFS attractor dimension via the coding map's Hölder section; the product-set lower inequality via Lipschitz projections; and the embedding-dimension lower bound `bldim(X) ≥ ⌈dimH X⌉`), each with a "key insight" and "Why now?" justification tied to the theorems just proved.

Note: the build root is the `Catalog/` subproject (module name `Geometry.FractalDimension`).