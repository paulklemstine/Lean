# Future Directions — Metric Filtration Rank Profiles as Tropical Valuation Objects

Derived from the research cycle in
`Catalog/Tropical/MetricFiltrationRankProfiles.lean` (foundation: `transEndo`,
`rankEndo`, `rankIv`, the tropical sandwich `rankEndo_submult` /
`rankEndo_sylvester`, `rankIv_mono_restrict`, `rankEndo_eventually_const`,
`trop_rankEndo_submult`) and
`Catalog/Tropical/MetricFiltrationRankProfilesFutureDirections.lean`
(`finrank_diamond`, `rankIv_diamond`, `persistentRank_mono`,
`persistentRank_ultrametric`, `rankEndo_submult_eq_of_inf_bot`,
`finrank_range_stability`, `rankEndo_single_step_stability`).

Each conjecture below is falsifiable and stated so it can be turned directly into
a Lean `theorem ... := by sorry` skeleton.

---

## D1 — Möbius inversion: the rank invariant is the cumulative transform of a nonnegative barcode

**Conjecture.** Extend the rank invariant past the diagonal by the *bar-count*
convention `rkBar T i j = finrank (something counting bars with birth ≤ i, death ≥ j)`
(which is **not** `0` for `i > j`). Then the box `mult T i j = rkBar(i,j) −
rkBar(i−1,j) − rkBar(i,j+1) + rkBar(i−1,j+1)` is `≥ 0` for *all* `i, j`, and
`rkBar` is recovered as the cumulative sum of `mult` over the interval poset
(Möbius inversion). Equivalently, a pointwise-finite persistence module has a
well-defined barcode multiplicity function.

**The key insight is** that our proved interior diamond `rankIv_diamond` already
supplies the supermodularity `rkBar(i,j) + rkBar(i−1,j+1) ≥ rkBar(i−1,j) +
rkBar(i,j+1)`; the *only* obstruction we found was the boundary, where the naive
`rankIv = 0 for i > j` convention is wrong because the genuine invariant counts
bars and stays positive across the diagonal.

**Why now?** We have a clean, axiom-light proof of the interior diamond via
two-term rank-nullity (`finrank_map_add_finrank_inf_ker`); the remaining work is
purely the boundary bookkeeping of Möbius inversion on `ℕ × ℕ`, which Mathlib's
`incidenceAlgebra` / `Finset` machinery now supports.

---

## D2 — The full equality locus of min-plus submultiplicativity (C4 iff)

**Conjecture.** The tropical lax morphism `trop_rankEndo_submult` is a genuine
semiring homomorphism on the block `[i, i+k+l]`, i.e.
`rankEndo T i (k+l) = min (rankEndo T i k) (rankEndo T (i+k) l)`, **iff** no rank
is lost in the interior — precisely
`ker (transEndo T (i+k) l) ⊓ range (transEndo T i k) = ⊥`
on the side that realizes the minimum — and this locus is in bijection with the
set of barcode death-times inside `[i, i+k+l]`.

**The key insight is** that `rankEndo_submult_eq_of_inf_bot` already proves the
*sufficient* direction (`⊥` intersection ⟹ equality on the left endpoint); the
converse and the combinatorial identification with death-times is what upgrades
"lax" to "exact."

**Why now?** The sufficient direction is done and isolates the exact submodule
`ker ⊓ range` whose vanishing controls equality; turning it into an iff only
requires the rank-nullity identity in the non-vanishing case, already packaged in
`finrank_map_add_finrank_inf_ker`.

---

## D3 — The rank profile is 1-Lipschitz in the tropical sup-metric (sharp C5)

**Conjecture.** Equip rank profiles with the tropical (min-plus) sup-metric
`d(R, R') = ⨆ i k, |R i k − R' i k|`. Then `T ↦ rankEndo_T` is **1-Lipschitz with
respect to the number of step indices where `T` and `T'` differ**, measured by
`∑ rank(T m − T' m)`: `d(rankEndo_T, rankEndo_T') ≤ ∑_m finrank (range (T m − T' m))`.

**The key insight is** that the correct local modulus is `rank(T m − T' m)` and
*not* `|rank(T m) − rank(T' m)|`: we proved (`finrank_range_stability`,
`rankEndo_single_step_stability`) that a single altered step moves the profile by
at most `rank(T m − T' m)`, and explicitly identified the literal "±1" conjecture
as **false** because two maps of nearby rank can differ arbitrarily as maps.

**Why now?** The single-step bound is a theorem; the multi-step bound is a finite
telescoping of single-step changes (replace differing steps one at a time), and
the tropical sup-metric is just `⨆` of the per-`(i,k)` bound.

---

## D4 — Dependent-family lift to genuine persistence modules (C1)

**Conjecture.** Replace the single ambient space `V` by a family `X : ℕ → Type`
with step maps `step i : X i →ₗ[K] X (i+1)`. With transitions built by
`Nat.add`-recursion and codomain transport `Nat.add_assoc ▸ ·`, all of
`rankEndo_submult`, `rankEndo_sylvester` (with `finrank V` replaced by the
*intermediate* `finrank (X (i+k))`), `rankIv_mono_restrict`, and `finrank_diamond`
hold verbatim.

**The key insight is** that every proof in the current development factors
through three space-agnostic facts — `LinearMap.range_comp`, the restricted
rank-nullity `finrank_map_add_finrank_inf_ker`, and `range_comp_le_range` — none
of which uses that domain and codomain coincide; only the Sylvester `dim V` term
references the ambient space, and it should become the intermediate dimension.

**Why now?** Our single-space proofs are deliberately written through
`transEndo_comp` and a single rank-nullity helper, so the dependent lift is a
transport exercise rather than a re-derivation; Lean's `▸`/`Eq.mpr` plus
`finrank`-invariance under `LinearEquiv` makes the bookkeeping tractable.

---

## D5 — Stabilization threshold = top barcode death-time (idempotency, C3)

**Conjecture.** The least threshold `N(i)` from `rankEndo_eventually_const`
(after which `rankEndo T i k = persistentRank T i`) equals the largest death-time
of a bar born at or before `i`; and the two-variable persistent rank
`R∞ T i j = ⨅ m, rankIv T i (j+m)` collapses to `persistentRank T i` for every
`j ≥ i`, making `R∞` a genuine ultrametric valuation with equality
`R∞ i k = min (R∞ i j) (R∞ j k)` exactly when `j ≥ N(i)`.

**The key insight is** that `persistentRank_mono` shows the stable rank is
monotone in the *starting* level, so `R∞` depends only on the source `i` — the
"min-plus idempotency" is then the statement that the antitone profile has flat
tail past `N(i)`, already witnessed by `rankEndo_eventually_const`.

**Why now?** Both ingredients (`persistentRank_mono`, eventual constancy) are
proved; pinning `N(i)` to a death-time only needs D1's barcode, closing the loop
between the tropical (valuation) and combinatorial (barcode) pictures.
