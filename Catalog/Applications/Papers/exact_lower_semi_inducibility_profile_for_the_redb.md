# Theorem Trace — Red-Blue Star S_{2,1} Lower Inducibility Profile

Internal anti-hallucination ledger. Every name below comes from the Phase A Lean
output. No result is stated in ARTICLE.md / RESEARCH_PAPER.md that is not listed here.

## From `RedBlueStarS21Profile.lean`
- `edgeDensity` (def): `edgeDensity t = t * (1 - t/2)`. The construction's edge density.
- `edgeDensity_one`: `edgeDensity 1 = 1/2`. (in ARTICLE: boundary example; in PAPER: §3)
- `edgeDensity_le_half`: for `t ∈ [0,1]`, `edgeDensity t ≤ 1/2`. (ARTICLE: ceiling; PAPER §3)
- `edgeDensity_strictMonoOn`: `edgeDensity` strictly increasing on `[0,1]`. (PAPER §3, bijection)
- `minProfile` (def): `minProfile t = t^2 * (1 - t)`. The candidate minimum profile.
- `exists_unique_param`: for `β ∈ [0,1/2]` there is a unique `t ∈ [0,1]` with `edgeDensity t = β`. (PAPER §3)
- `claim_illposed_above_half`: the universal-β claim fails for `β > 1/2`. (ARTICLE & PAPER §4)
- `refutation_three_quarters`: explicit refutation witness at `β = 3/4`. (PAPER §4)

## From `RedBlueStarS21Optimization.lean`
- `starFunctional` (def): `starFunctional d = d^2 * (1 - d)`. Per-vertex functional.
- `minProfile_eq_starFunctional`: `minProfile t = starFunctional t`. (PAPER §2)
- `starFunctional_nonneg`: `0 ≤ starFunctional d` on `[0,1]`. (PAPER §5)
- `starFunctional_le`: `starFunctional d ≤ 4/27` on `[0,1]`; certificate `(3d-2)^2`. (ARTICLE & PAPER §5)
- `starFunctional_max`: `starFunctional (2/3) = 4/27`. (ARTICLE & PAPER §5)
- `construction_profile_le_max`: `minProfile t ≤ 4/27` on `[0,1]`. (PAPER §5)
- `relaxed_infimum_zero`: two-point law mass β at d=1, 1-β at d=0 has mean β and f-average 0. (ARTICLE & PAPER §6)

## From `RedBlueStarS21CatalogBridge.lean`
- `edgeDensity_lt_nwThreshold`: for `t ∈ [0,1]`, `l ≥ 2`, `edgeDensity t < nwThreshold l`. (PAPER §7)
- `edgeDensity_ceiling_lt_C5`: `edgeDensity 1 < nwThreshold 5`, i.e. `1/2 < 5/8`. (ARTICLE & PAPER §7)

## From `C5Threshold.lean` (imported)
- `nwThreshold` (def): `nwThreshold l = l / (2l - 2)`.
- `nwThreshold_five`: `nwThreshold 5 = 5/8`.
- `nwThreshold_gt_half`: for `l ≥ 2`, `1/2 < nwThreshold l`.
- `nwThreshold_strictAnti`: `nwThreshold` strictly decreasing in `l`.
