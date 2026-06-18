# Summary of changes for run 01ed5d53-7498-4d1a-8326-4312c9487ae4
I added a single coherent, fully-proved Lean file formalizing the requested "Bridge XII" continuation:

`Catalog/Applications/BoltzmannBridge/InterleavingGeodesicPullback.lean`

It builds directly on the existing Boltzmann Bridge files (the weight-sup characterization `eInterleavingDist_eq_weightSupEDist`, the contravariant `pullback` functor with its surjective isometry `eInterleavingDist_pullback_eq_of_surjective`, and the affine geodesic `lerp`). Everything is in a fresh namespace `BoltzmannBridge.BridgeXII` to avoid clashing with the existing Bridge XI declarations, and every theorem has a complete proof.

Contents (all proved, no `sorry`, axioms limited to `propext`/`Classical.choice`/`Quot.sound`):
1. `pullback_lerp` — pullback commutes with the affine interpolation: `pullback f (lerp F G t) = lerp (pullback f F) (pullback f G) t` (both sides are the same affine combination of reindexed weights).
2. `eInterleavingDist_pullback_lerp_eq_of_surjective` — the requested path-level distance preservation: for a vertex-level **surjective** `f`, `d(pullback f (lerp F G s), pullback f (lerp F G t)) = d(lerp F G s, lerp F G t)`. This is the strongest precise variant the API supports; surjectivity is the hypothesis matching the catalog's `eInterleavingDist_pullback_eq_of_surjective`.
3. `eInterleavingDist_pullback_lerp_speed_of_surjective` — the same value in constant-speed form `ofReal |s − t| · d(F, G)`.
4. An explicit finite counterexample over `Bool` showing surjectivity is necessary: `cexMap : Unit → Bool`, two filtrations `cexF`, `cexG` whose pullbacks coincide, with `exists_pullback_strict_contraction` (object-level strict contraction) and `exists_pullback_lerp_strict_contraction` (the whole geodesic collapses to a point under pullback while the upstream geodesic has positive length for `s ≠ t`). Distances are computed exactly via the weight-sup formula.

A sheaf interpretation is mentioned only in a parenthetical comment; the formal content is purely metric/functorial.

Build note: the catalog's real Lean package lives in `Catalog/` (`Catalog/lakefile.toml`), and the `Applications/` directory was not registered as a library, so its modules could not be built or imported. I added an `Applications` library entry (`globs = ["Applications.+"]`) to `Catalog/lakefile.toml`; it is not part of `defaultTargets`, so default builds are unaffected, but the Boltzmann Bridge files and the new file now compile. The new file and its full dependency chain build successfully under Lean v4.28.0 / Mathlib.