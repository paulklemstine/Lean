# THEOREM TRACE — EML Interpolation Theory (Jackson Rates)

Internal anti-hallucination ledger. Every name below appears in the Phase A Lean
output. No result is stated in the prose that is not traceable to this list.

## Files
- `Catalog/EML/LipschitzJacksonRate.lean` — Lipschitz (α = 1) Jackson rate; defines
  `pwLinInterp` and `pwLinInterp_locate`.
- `Catalog/EML/HolderJacksonRate.lean` — full Hölder (Lip_α) Jackson rate; imports the above.

## Definitions / locating lemma (from LipschitzJacksonRate.lean)
- **`pwLinInterp f n x`** — continuous piecewise-linear interpolant of `f` on the
  uniform grid of `n` cells over `[0,1]`. On the cell containing `x`, with
  `k = min(n-1, ⌊n·x⌋)`, `a = k/n`, `b = (k+1)/n`, it equals
  `f a + (f b − f a)/(b − a) · (x − a)`.
- **`pwLinInterp_locate n hn x hx`** — for `x ∈ [0,1]` and `n ≥ 1`, `x` lies in the
  cell `[a,b] = [k/n, (k+1)/n]`.

## Theorems (from HolderJacksonRate.lean)
- **`holderInterp_error`** — single-cell bound. For `f` α-Hölder with constant `L`
  (`0 < α`, `0 ≤ L`, `|f x − f y| ≤ L·|x−y|^α`), `a < b`, `x ∈ [a,b]`:
  `|f x − (f a + (f b − f a)/(b − a)·(x − a))| ≤ 2·L·(b − a)^α`.
  → ARTICLE.md ("the one-cell estimate"); RESEARCH_PAPER.md Theorem 1.

- **`pwLinInterp_holder_error`** — global Jackson rate. For the same `f`, `n ≥ 1`,
  `x ∈ [0,1]`: `|f x − pwLinInterp f n x| ≤ 2·L / n^α`.
  → ARTICLE.md ("the main theorem"); RESEARCH_PAPER.md Theorem 2.

- **`pwLinInterp_holder_tendsto`** — convergence. For `x ∈ [0,1]`,
  `pwLinInterp f n x → f x` as `n → ∞`.
  → ARTICLE.md ("the limit"); RESEARCH_PAPER.md Theorem 3.

## Companion result referenced (LipschitzJacksonRate.lean, α = 1)
- The same `pwLinInterp` attains the sharp Lipschitz rate `L/n` (the `α = 1` slice,
  with the sharper constant `1` rather than `2`).

## Cross-links named in Phase A (context only, not restated as our theorems)
- `EML.MonotoneSeparation` (point separation), `EML.QuadraticApproxRate`
  (`eml_two_witnesses_sq`, x² via a single-exponential network),
  `EML.QuadraticApproxLowerBound`, `EML.AlgebraicMaxClosure`
  (`approx_add`, `approx_mul`).
