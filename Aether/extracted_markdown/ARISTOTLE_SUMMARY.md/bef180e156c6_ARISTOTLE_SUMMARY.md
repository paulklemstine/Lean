# Summary of changes for run 72a69aef-32e5-48ed-838c-3cbba94d561d
Completed a research cycle extending the `Bridges.CategoricalTropicalRipsInterleaving` catalog file, following the team-loop methodology. All new results are fully proved (0 sorries) and verified to use only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

## New Lean files (in `Catalog/Bridges/`)

**`CategoricalTropicalRipsRank.lean` — Conjecture 5 (rank/Betti curves are 1-Lipschitz).**
- `rankMod : PersMod (Set β) → PersMod ℕ` (for `Finite β`): the rank curve `t ↦ ncard (M.obj t)`, proved monotone.
- `rank_preserves_interleaving`: the rank functor sends `ε`-interleavings to `ε`-interleavings ("algebraic stability of the rank invariant").
- `rank_interleavingDist_le`: the rank functor is 1-Lipschitz for the interleaving distance (via `sInf` monotonicity).
- `rips_rank_stability` / `rips_rank_interleavingDist_le`: specialisation to Vietoris–Rips edge-count/Betti-0 curves over a finite point set, reusing the catalog's `rips_stability`.

**`CategoricalTropicalRipsShift.lean` — Conjectures 2 & 4 (shift action + finite-distance equivalence).**
- `shift c M`, `interleaved_shift_iff`, and `interleavingDist_shift`: the constant shift is a strict isometry of the interleaving distance.
- `interleaved_self_shift` / `interleavingDist_self_shift`: a module is `c`-close to its own `c`-shift (`≤ ENNReal.ofReal c`).
- `trop_interleavingDist_self`: the self-distance is the tropical unit `1 = trop 0` (computed from the catalog's `interleavingDist_self`).
- `FinInterleaved`, `finInterleaved_equivalence` (transitivity via the catalog's `Interleaved.trans`), and `finInterleaved_iff_dist_ne_top` characterising it as `interleavingDist ≠ ⊤` (using `Interleaved.weaken` and `sInf_empty`).

Both files contain `-- !-- Lab Notes -- !--` blocks documenting the Hypothesis / Experiment / Analysis / Critique / Synthesis stages, and each main theorem uses insight-bearing tactics (structural `refine`, `by_contra`, `linarith`, set/`sInf` arguments) and genuinely builds on the catalog's definitions and lemmas.

**`FUTURE_DIRECTIONS.md`** (in `Catalog/Bridges/`) lists 5 bold, falsifiable conjectures derived from this cycle's findings (strictness of the rank contraction, tightness of the shift displacement, the finite-distance quotient metric, universality/maximality of the rank functor, and 2-point sharpness), each with a "The key insight is…" sentence and a "Why now?" justification.

## Build fix
The top-level `lakefile.toml` could not locate its source directories (sources live under `Catalog/`), so no module could build. I added the minimal `srcDir = "Catalog"` setting to the package config; the existing bridge file and both new modules now build cleanly. (A separate, pre-existing missing file elsewhere in the catalog, `Algebra/SumThreeCubes/Defs.lean`, still breaks the all-targets default build, but it is unrelated to this work; the relevant modules build individually.)