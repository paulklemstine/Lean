# Summary of changes for run b5b100c4-c76c-4aed-99a9-4fffacf40a1f
## Reversible Computing and Thermodynamic Efficiency — new Lean 4 results

I produced two new, fully-proved Lean files (0 `sorry`, standard axioms only) extending the existing catalog files `Computation/ReversibleTropicalThermodynamics.lean` and `Computation/TightAncillaBound.lean`, plus a `FUTURE_DIRECTIONS.md`.

### `Catalog/Computation/LandauerLowerBound.lean` — the general principle
The catalog previously had only the *exact* Landauer cost for *uniform n-bit erasure* and a *zero-loss* characterization of *bijections*. This file proves the unifying inequality those are special cases of: the **deterministic data-processing inequality**.
- `shannonEntropy_pushforward_le`: for an arbitrary `f : α → β` and any nonnegative weights `p`, `H(f∗p) ≤ H(p)` — a deterministic computation never increases Shannon entropy.
- `shannonEntropy_pushforward_of_injective`: reversible (injective) maps preserve entropy exactly.
- `landauer_lower_bound` / `landauer_lower_bound_zero_of_injective`: dissipated heat `k·T·(H(p) − H(f∗p))` is always ≥ 0, and exactly 0 for reversible maps.
The proof avoids concavity/grouping machinery: the whole argument reduces to the pointwise fiber-domination `f∗p(f x) ≥ p x` and monotonicity of `log`.

### `Catalog/Computation/ReversibleGates.lean` — concrete optimal gates (cross-domain synthesis)
Constructs the universal reversible gates CNOT, Toffoli, Fredkin as honest bijections and proves all three required properties, feeding their bijectivity into BOTH the catalog's `reversible_zero_entropy_cost` AND the new `landauer_lower_bound_zero_of_injective`:
- reversibility (`*_involutive`, `*_bijective`),
- logical correctness (`cnot_computes_xor/_copy`, `toffoli_computes_and/_not`, `fredkin_swaps_when_control`),
- thermodynamic optimality (`*_zero_entropy_loss`, `*_landauer_zero`: zero entropy loss and zero dissipated heat on every input distribution).

Both files include `-- !-- Lab Notebook --!--` blocks (Hypothesis/Result/Insight/Failure analysis) and `-- !-- comment -- !--` proof sketches. `FUTURE_DIRECTIONS.md` gives a synthesis, results summary, and 5 falsifiable directions (quantitative equality form of Landauer via fiber conditional entropy; subadditivity of pipeline cost via pushforward functoriality; Bennett embedding saturating the bound; Toffoli universality tied to the tight ancilla bound; the reversible-computation group action preserving entropy), each with a "key insight" and "Why now?".

### Build note
The repository's root `lakefile.toml` listed library globs (`Computation.+`, etc.) but the sources live under `Catalog/`, so the root project did not build as-is. I added `srcDir = "Catalog"` to the root `lakefile.toml`; the unchanged `Catalog/lakefile.toml` still works, so this is strictly an improvement. All new modules build successfully via `lake build` and depend only on `propext`, `Classical.choice`, `Quot.sound`.