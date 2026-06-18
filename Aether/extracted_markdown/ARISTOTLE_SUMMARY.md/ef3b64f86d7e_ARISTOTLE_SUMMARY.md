# Summary of changes for run f933c4e3-7565-40f1-b4a2-d720035be53b
Created **Boltzmann Bridge XI**, the "curvature" layer of the persistence-stability arc, in a new file `Catalog/Applications/BoltzmannBridge/InterleavingGeodesicConvexity.lean`.

## What was proved (5 theorems, 0 sorries)
Building directly on the existing catalog bridges — `eInterleavingDist_lerp` (Bridge IX), `lerp_lerp` (Bridge X), and the sup-isometry `eInterleavingDist_eq_weightSupEDist` (Bridge VIII) — the file establishes that the interleaving metric on filtrations is **convex / non-positively curved (Busemann)**:

- `lerp_reverse` — affine reversal symmetry `lerp F G t = lerp G F (1−t)`.
- `lerp_self` — constant geodesics are stationary, `lerp F F t = F`.
- `weightSupEDist_lerp_bicombing` — the convexity bound at the sup-distance level (the only nontrivial step: the per-simplex triangle inequality `|(1−t)a + tb| ≤ (1−t)|a| + t|b|` transported through a `⨆`).
- `eInterleavingDist_lerp_bicombing` — the **convex geodesic bicombing** inequality `d(lerp F G t, lerp F' G' t) ≤ ofReal(1−t)·d(F,F') + ofReal t·d(G,G')`, i.e. Busemann convexity of the interleaving metric.
- `eInterleavingDist_lerp_convex` — convexity of the distance to a fixed filtration along a geodesic, recovered as the constant-geodesic special case via `lerp_self`.

Each theorem is verified to depend only on the standard kernel axioms (`propext`, `Classical.choice`, `Quot.sound`). The file includes brief `-- !-- ... -- !--` proof sketches per theorem and a full `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis), including boundary-condition notes on why `0 ≤ t ≤ 1` is intrinsic and why the bound is convex-flat rather than strict.

## FUTURE_DIRECTIONS.md
Added `Catalog/Applications/BoltzmannBridge/FUTURE_DIRECTIONS.md` with a synthesis, results summary, and 5 falsifiable research directions (bundling a `ConvexGeodesicBicombing`/Busemann certificate; strict-convexity defect = multiplicity of supremising simplices; 1-Lipschitz nonexpansiveness via `sup_le`; a reverse/lower bicombing bound; descent of convexity to the metric quotient and the Vietoris–Rips locus), each with a "The key insight is..." and a "Why now?" justification.

## Build-configuration fix
The `Applications/*` source tree (which holds the entire BoltzmannBridge series) was not declared in either lakefile, so its modules could not be resolved or built. I added an `Applications` `lean_lib` glob to both `lakefile.toml` and `Catalog/lakefile.toml`, and set `srcDir = "Catalog"` on the top-level package so module names resolve correctly from the project root. These are additive fixes (the new lib is not added to `defaultTargets`, so unrelated pre-existing broken targets are unaffected). The new file and its full dependency chain build cleanly.