# Summary of changes for run 2136a821-a011-4db0-80f6-16a19e47ec6d
Researched the direction **"Metric filtration rank profiles as tropical valuation objects"** and produced verified Lean 4 results.

## What was built

New, fully-proved file `Catalog/Tropical/MetricFiltrationRankProfiles.lean` (0 sorries; only standard axioms `propext`, `Classical.choice`, `Quot.sound`). It formalizes the rank profile of a discrete metric filtration / persistence module in the single-ambient-space model: a fixed finite-dimensional space `V` and step endomorphisms `T`, with composite transitions `transEndo T i k` and rank profile `rankEndo T i k = finrank (range (transEndo T i k))`.

Main theorems proved:
- `transEndo_add` — functoriality (concatenation) of transition maps.
- `rankEndo_diag` — full rank on the diagonal.
- `rankEndo_le_left`, `rankEndo_le_right`, `rankEndo_antitone` — interval/length monotonicity.
- `rankEndo_submult` — **min-plus (tropical ⊗) submultiplicativity**: `rankEndo T i (k+l) ≤ min (rankEndo T i k) (rankEndo T (i+k) l)`.
- `rank_comp_sylvester` + `rankEndo_sylvester` — the **Frobenius/Sylvester additive lower bound**, giving a two-sided "tropical sandwich" of the composite rank.
- `tropRank` + `trop_rankEndo_submult` — packaging the profile as a lax morphism into Mathlib's tropical semiring `Tropical (WithTop ℕ)`.
- `rankEndo_eventually_const` — every rank profile stabilises (existence of a persistent rank).
- `rankIv` + `rankIv_mono_restrict` — the classical TDA rank invariant in absolute (start, end) coordinates and its monotonicity under interval restriction, shown to be the persistence-theoretic shadow of tropical submultiplicativity.

## Lab notes
Inline `-- !-- Lab Notes -- !--` blocks document the central hypothesis (rank invariant as a min-plus valuation), the design experiment (relative (start, length) indexing to avoid dependent-type/`Nat.add_assoc` transport friction), and the insight that the classical TDA monotonicity axiom coincides with tropical submultiplicativity.

## Future directions
`Catalog/Tropical/FUTURE_DIRECTIONS.md` lists five precise, testable conjectures: (C1) dependent-family generalisation, (C2) Möbius/barcode nonnegativity structure theorem, (C3) tropical idempotency/ultrametric law for the persistent rank, (C4) when the lax tropical morphism is a genuine homomorphism, and (C5) a tropical Lipschitz stability bound.

The new file builds cleanly with no errors, warnings, or sorries.