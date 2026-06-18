# Summary of changes for run fd79faf4-f33c-469c-aa9b-74eb5960d903
## Self-Avoiding Walks: Existence of the Connective Constant

I extended the existing catalog file `Computation/SelfAvoidingWalk/Basic.lean` (which had proved submultiplicativity of the SAW count `c_n` on ℤ² but never proved that `c_n^{1/n}` converges) with a new file:

**`Computation/SelfAvoidingWalk/ConnectiveConstant.lean`** — imports and builds directly on the catalog's `sawCount`, `sawCount_submultiplicative`, `logSawCount_subadditive`, and `connectiveConstant`.

### Theorems proved (sorry-free; only standard axioms `propext`/`Classical.choice`/`Quot.sound`)
- `sawCount_log_div_tendsto` — Fekete's lemma for SAWs: `(log c_n)/n` converges (the existence statement), via Mathlib's `Subadditive.tendsto_lim` applied to the catalog's subadditivity.
- `connectiveConstant_eq_exp_lim` — identifies the catalog's *definition* of `μ` with the Fekete limit, upgrading it to a characterization.
- `sawCount_rpow_tendsto` — **Hammersley–Morton**: `c_n^{1/n} → μ` (the connective constant exists as the limit of root-counts). *Main result.*
- `connectiveConstant_le_rpow` — `μ ≤ c_n^{1/n}` for every `n ≥ 1`: every finite count is a rigorous upper bound on `μ`.
- `one_le_connectiveConstant` — `1 ≤ μ`.
- `twoPow_le_sawCount` — `2^n ≤ c_n`, proved by an explicit injection of the `2^n` north-east (monotone) walks into self-avoiding walks (with seven supporting lemmas: start, per-step increments, coordinate sum, adjacency, and two injectivity facts).
- `two_le_connectiveConstant` — **`2 ≤ μ`**, the standard lower bound.

### Conjecture (intentionally left as `sorry`, per the generalization/boundary step)
- `connectiveConstant_le_three` — the matching upper bound `μ ≤ 3` (needs the non-reversal count `c_n ≤ 4·3^{n-1}`).

### Critic's correction
The brief's proposed value `μ = (2+√2)/2 ≈ 1.707` is incorrect for ℤ². It conflates the *hexagonal* Nienhuis/Duminil-Copin–Smirnov constant `√(2+√2) ≈ 1.848` (already in the catalog as `nienhuis_mu`) with the ℤ² constant, which has no known closed form and satisfies `2 ≤ μ ≤ 3` (numerically ≈ 2.638). This is documented in the file header, so existence + rigorous bounds are proved rather than a spurious exact value.

### Notes
- Lab Notebook blocks (`-- !-- ... -- !--`) document hypothesis/result/insight/failure-analysis for each major theorem.
- `FUTURE_DIRECTIONS.md` (in the same directory) contains the required Synthesis, Results Summary, and five falsifiable research directions (close `μ ≤ 3`; Hammersley–Welsh correction; supermultiplicative bridge sandwich; generating-function radius `= 1/μ`; and porting the existence pipeline to discharge the hexagonal `duminilCopin_smirnov` sorry).

Verified with `lake build`: the module compiles and the only remaining `sorry` is the explicitly-declared conjecture.