# Summary of changes for run b12c6c3f-46ba-45c8-b860-c7fd3fe1e933
Completed a full research cycle on **Metric Filtration Rank Profiles as Tropical Valuation Objects** (Combinatorics / TDA). The referenced base file did not exist (cold start), so I built the foundation and the conjecture extensions from scratch, all fully proved (0 sorries, standard axioms only).

**Build fix:** the project's `lakefile.toml` was missing `srcDir`, so nothing compiled (modules import `Tropical.*` but live under `Catalog/`). Added `srcDir = "Catalog"`, after which the project builds.

**New files (all theorems machine-verified, 0 sorries):**

1. `Catalog/Tropical/MetricFiltrationRankProfiles.lean` — the foundation in the single-ambient-space model: definitions `transEndo`, `rankEndo`, `rankIv`, `persistentRank`, `tropRank`, and the tropical sandwich:
   - `rankEndo_submult` — min-plus submultiplicative upper bound;
   - `rankEndo_sylvester` — Frobenius/Sylvester additive lower bound;
   - `rankIv_mono_restrict` — rank invariant monotone under interval restriction;
   - `rankEndo_eventually_const` — stabilization (persistent rank exists);
   - `trop_rankEndo_submult` — lax morphism into `Tropical (WithTop ℕ)`.

2. `Catalog/Tropical/MetricFiltrationRankProfilesFutureDirections.lean` — proofs of conjectures C2–C5:
   - **C2** `finrank_diamond` (2-D Sylvester / supermodularity) and `rankIv_diamond` (box-multiplicity nonnegativity, interior);
   - **C3** `persistentRank_mono` and `persistentRank_ultrametric`;
   - **C4** `rankEndo_submult_eq_of_inf_bot` (sufficient condition for equality in the min-plus bound);
   - **C5** `finrank_range_stability` and `rankEndo_single_step_stability`.

   A key scientific finding (documented in the Lab Notes): the **literal C5** ("step ranks differ by ±1 ⟹ profile changes by ≤1") is **false** — the correct Lipschitz modulus is `rank(X − X')`, which the proved theorems use. Also identified that C2's box is only nonnegative in the interior under the stated `rankIv = 0 for i>j` convention.

Both files contain `-- !-- Lab Notes -- !--` blocks recording the Hypothesize/Experiment/Analyze/Critique loop.

3. `Catalog/Tropical/FUTURE_DIRECTIONS.md` — five bold, falsifiable conjectures (D1 Möbius/barcode inversion, D2 full C4 iff, D3 sharp 1-Lipschitz stability, D4 dependent-family lift, D5 stabilization threshold = top death-time), each with a "The key insight is..." sentence and a "Why now?" justification, derived from this cycle's findings.

All theorems were verified to depend only on `propext`, `Classical.choice`, and `Quot.sound`. No axioms, `sorry`, `native_decide`-only proofs, or `@[implemented_by]` were introduced.