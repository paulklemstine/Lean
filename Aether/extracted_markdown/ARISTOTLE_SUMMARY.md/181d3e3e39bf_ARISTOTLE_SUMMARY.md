# Summary of changes for run 529a8887-a3bf-43f0-9a57-34fb6c3b29fb
Created the standalone core file `Catalog/LinearAlgebra/MetricFiltrationRankProfilesCore.lean` formalizing the finite-dimensional linear-algebra core for rank profiles of iterated endomorphisms. It compiles cleanly (no `sorry`, only standard axioms) and was registered as a new `LinearAlgebra` library in `Catalog/lakefile.toml`.

Contents (in namespace `MetricFiltrationRankProfiles`, over `{K V}` with `[Field K] [AddCommGroup V] [Module K V]`, and `[FiniteDimensional K V]` where needed):
- `transEndo T i k : V →ₗ[K] V` — composition of the `k` consecutive maps of `T` starting at index `i`, defined recursively with `transEndo T i 0 = LinearMap.id` and `transEndo T i (k+1) = (T (i+k)).comp (transEndo T i k)` (so the successor appends on the left, making the concatenation law natural; `T i` is applied first).
- `rankEndo T i k : ℕ := Module.finrank K (LinearMap.range (transEndo T i k))`.
- Simp lemmas: `transEndo_zero`, `transEndo_succ`, `transEndo_one`, `rankEndo_zero` (`= finrank K V`), plus `rankEndo_def`.
- `transEndo_add : transEndo T i (k + l) = (transEndo T (i + k) l).comp (transEndo T i k)`, proved by induction on `l`.
- `rankEndo_le_left : rankEndo T i (k + l) ≤ rankEndo T i k` (via `transEndo_add`, `LinearMap.range_comp`, `Submodule.finrank_map_le`).
- `rankEndo_le_right : rankEndo T i (k + l) ≤ rankEndo T (i + k) l` (via `transEndo_add`, `LinearMap.range_comp_le_range`, `Submodule.finrank_mono`).
- `rankEndo_submult : rankEndo T i (k + l) ≤ min (rankEndo T i k) (rankEndo T (i + k) l)`.

No Fibonacci/unrelated material was included. A Sylvester/Frobenius-type lower bound was deliberately omitted: a search of Mathlib found only the composition upper bounds (e.g. `LinearMap.rank_comp_le_left/right`) and no usable lower-bound analogue for `finrank` of a composition, matching the task constraint to stop at results obtainable directly from existing Mathlib lemmas.