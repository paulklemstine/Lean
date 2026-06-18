# Summary of changes for run 48bdc6e2-1f1f-40b5-a5d2-2f7c27cf92c6
Researched the mission "Functorial tropical valuation profiles of topological CSS codes via Smooth Poincaré intersection primitives" and delivered a new, fully verified Lean 4 file plus a future-directions note, extending the existing `Applications/SmoothPoincare` code-theory program.

## New file: `Catalog/Applications/SmoothPoincare/TropicalCSSProfiles.lean`
Fully compiles, 0 sorries, clean axioms (`propext`, `Classical.choice`, `Quot.sound`, plus `Lean.ofReduceBool`/`Lean.trustCompiler` only in one `native_decide` cardinality check). It unifies the catalog's tropical weight enumerators (`twe`/`twePlus`) with its direct-sum structure (`⊕c`) around the **tropical valuation profile** `(minWt C, maxWt C)`. Main theorems proved:

- **Two-line law** `twe_eq_min_lines` / `twePlus_eq_max_lines`: for every nonempty code and every real slope `t`, `twe C t = min((minWt C)·t)((maxWt C)·t)` and the max-plus dual — generalizing the catalog's `hamming_twe = min(0,8t)` to arbitrary codes (the tropical enumerators see only the two extreme weights).
- **Profile gap** `twePlus_sub_twe = (maxWt − minWt)·|t|`.
- **Concavity/convexity** `twe_concave`, `twePlus_convex` in the tropical variable.
- **Functoriality** `minWt_append`, `maxWt_append`: the profile is a monoid homomorphism `(codes, ⊕c) → (ℕ, +)`, the structural reason behind `twe_append`.
- **Saturation rigidity** (cycle 2) `wt_eq_length_iff`, `maxWt_eq_length_iff`: `maxWt C = n ↔ ones n ∈ C`, pinning the upper slope to a single membership test.
- **CSS commutation layer**: `CrossOrthogonal` (CSS stabilizer-commutation), closure under direct sum `appendCode_crossOrthogonal`, and the redundancy product law `cssRedundancy_append`.
- **Hamming instantiations** (mod-2 shadow of E8): `hamming_minWt = 0`, `hamming_maxWt = 8`, `hamming_twe_from_profile`, `hamming_crossOrthogonal`, `hamming_cssRedundancy = 256` (a `[[8,0,4]]` stabilizer state), and `hamming16_crossOrthogonal`, `hamming16_cssRedundancy = 65536` derived via the product law.

## Lab Notes
Inline `-- !-- Lab Notes -- !--` blocks (cycle 1 and cycle 2) document the hypotheses, experimental outcomes, insights (the tropical valuation functor; the "information loss" of `twe`), and critique/failure analysis.

## FUTURE_DIRECTIONS.md
Five precise, falsifiable conjectures for follow-up cycles: tensor multiplicativity of the profile (semiring-functor upgrade), saturation rigidity of `maxWt`, CSS quantum distance as a tropical-min invariant, Gleason saturation ⇒ length divisibility for CSS codes, and the strict coarseness of the profile vs. the weight distribution (irrecoverability of minimum distance).

## Build note
The project's `lakefile.toml` had no library matching the `Catalog.*` module layout (its globs referenced non-existent top-level directories), so no Catalog module could build or be checked. I added a `Catalog` library entry (globs `["Catalog.+"]`) without removing any existing configuration; all `Catalog.Applications.SmoothPoincare` modules, including the new file, now build successfully.