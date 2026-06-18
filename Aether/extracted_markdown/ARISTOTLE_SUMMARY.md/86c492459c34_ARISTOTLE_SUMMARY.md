# Summary of changes for run 4313f0f2-8ea6-4326-a950-6c4e11a6cd5d
## Boltzmann Bridge XII — Sheaf-Theoretic Transport and the ℓ∞ Curvature Obstruction

I added one new Lean file and a research-directions document that extend the existing BoltzmannBridge interleaving-metric arc in the catalog, reading the persistence interleaving distance through a local-to-global / sheaf lens.

### New Lean file
`Catalog/Applications/BoltzmannBridge/InterleavingSheafTransport.lean` — builds directly on the catalog foundations (`eInterleavingDist_eq_weightSupEDist`, `pullback`/`pullback_lerp`, `eInterleavingDist_pullback_eq_of_surjective`, `lerp`, `ofWeight`, `eInterleavingDist_convex`). It proves **4 main theorems** (plus 3 supporting lemmas and 2 definitions), all with `sorry`-count 0 and depending only on the allowed axioms `propext`, `Classical.choice`, `Quot.sound`:

1. `eInterleavingDist_pullback_lerp_eq_of_surjective` — **sheaf gluing / sharp transport**: along a surjective vertex map (a cover) restriction sends the geodesic to a constant-speed geodesic of *exactly* the same speed, upgrading Bridge XI's contraction inequality to a path-level isometry.
2. `pullback_straightLineContraction` — **naturality**: restriction commutes with the entire two-parameter contraction homotopy, so `pullback f` is a morphism of contractible path spaces.
3. `eInterleavingDist_convex_strict` — the **ℓ∞ curvature obstruction**: an explicit triple over `Fin 2` realises a strictly positive Busemann defect, proving the interleaving space is geodesic and Busemann-convex yet **not uniquely geodesic, hence not CAT(0)**.
4. `eInterleavingDist_pullback_lerp_lt_of_not_surjective` — the **obstruction class of a subcover**: restriction along the non-surjective `Fin 1 → Fin 2` strictly contracts the geodesic (endpoints collapse to distance 0 against a positive upstream length).

The file includes the required `-- !-- ... -- !--` proof-sketch blocks for each result and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

### Research directions
`Catalog/Applications/BoltzmannBridge/FUTURE_DIRECTIONS.md` — a narrative synthesis, results table, and 4 falsifiable conjectures (graded curvature defect over `Fin n`; the full surjective ⇔ path-isometry trichotomy; a Mayer–Vietoris/gluing law for jointly surjective covers; geodesic non-convexity of the Vietoris–Rips locus), each with a "The key insight is…" sentence and a "Why now?" justification.

### Build configuration
The catalog's `Applications` source tree was not attached to any lake library, so it was not buildable as-is. I added an `Applications` lean_lib (glob `Applications.+`) to `Catalog/lakefile.toml`, and a matching entry with `srcDir = "Catalog"` to the top-level `lakefile.toml`, so the new module builds from the project root. The new file and all pre-existing BoltzmannBridge modules compile successfully.