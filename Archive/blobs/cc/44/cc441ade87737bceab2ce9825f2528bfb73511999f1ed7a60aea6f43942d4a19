# Future Directions — Categorical Tropical Rips Interleaving (Sharpness, Quotient & Tightness cycle)

This cycle added **three fully-verified files (0 `sorry`s)** extending the
`Bridges.CategoricalTropicalRips*` family:

- `Bridges.CategoricalTropicalRipsShiftTight` — **Conjecture B discharged.**
  The catalog's displacement bound `interleavingDist M (shift c M) ≤ ofReal c` is
  **tight**: `interleavingDist_self_shift_eq` proves equality
  `interleavingDist M (shift c M) = ENNReal.ofReal c` for any module strictly monotone on a
  real interval longer than `c` (`Interleaved.shift_lower_bound` is the threshold-extraction
  lower bound), with the tropical reformulation `trop_interleavingDist_self_shift_eq`.
- `Bridges.CategoricalTropicalRipsRankSharp` — **Conjecture E discharged.**
  On a two-point space the rank/Betti-0 curve stability is an **equality**:
  `rips_rank_two_point` proves
  `interleavingDist (ripsRankCurve (twoPtMetric r)) (ripsRankCurve (twoPtMetric r'))
   = ENNReal.ofReal |r - r'|`, so the catalog's general 1-Lipschitz contraction
  `rips_rank_interleavingDist_le` is sharp here (saturation `twoPt_rank_full`, strict drop
  `twoPt_rank_lt`, extraction `two_point_le`).
- `Bridges.CategoricalTropicalRipsQuotient` — **Conjecture C discharged in corrected form.**
  The literal Conjecture C (quotient by `FinInterleaved`) is **false** (positive finite
  distances are not identified). The corrected statement quotients by the *distance-zero*
  relation: `interleavingDist_eq_of_dist_zero` (descent), `distZeroSetoid`, `quotDist`
  (`Quotient.lift₂`), `quotDist_self/comm/triangle`, point separation
  `quotDist_eq_zero_iff`, and the tropical law `quot_tropical_submul`.

The following are bold, falsifiable targets for the next cycles.

## Conjecture F (The two-point sharpness is the *only* sharp case for `ncard` rank)
Extending Conjecture E: for **every** finite point set with `≥ 3` points there exist
dissimilarities `d, d'` for which `rips_rank_interleavingDist_le` is **strict**, i.e.
`interleavingDist (ripsRankCurve d) (ripsRankCurve d') < ENNReal.ofReal (sup‖d - d'‖)`,
so two points is the *unique* cardinality at which the rank curve is an isometric invariant.
**The key insight is** that `twoPt_rank_lt` used the single off-diagonal edge to force a
strict cardinality drop; with `≥ 3` points the edge lattice has *non-nested* equal-size
antichains, so `ncard` collapses a permutation perturbation that still costs positive
lattice-level interleaving distance — exactly the mechanism of the still-open Conjecture A.
**Why now?** This cycle isolated both the saturation and strict-drop lemmas
(`twoPt_rank_full`, `twoPt_rank_lt`) and the threshold extraction `two_point_le`; a 3-point
witness reuses the same `Set.ncard_lt_ncard` machinery plus one explicit non-nested pair of
edge sets, upgrading "1-Lipschitz" to "strictly contracting at every cardinality `> 2`".

## Conjecture G (`shift` realizes an isometric `ℝ≥0`-action on the quotient metric)
On the distance-zero quotient `IsoClass α`, the constant shift descends to a well-defined
map `shiftQuot c : IsoClass α → IsoClass α` and the assignment `c ↦ shiftQuot c` is an
**isometric monoid action** with `quotDist (shiftQuot c q) (shiftQuot c q') = quotDist q q'`
and `quotDist q (shiftQuot c q) = ENNReal.ofReal c` on strictly monotone representatives.
**The key insight is** that the catalog's `interleavingDist_shift` (a strict isometry) makes
`shift` send distance-zero classes to distance-zero classes, so `Quotient.lift` descends it,
and this cycle's `interleavingDist_self_shift_eq` pins the displacement to exactly `c`.
**Why now?** Both the isometry (`interleavingDist_shift`) and the tight displacement
(`interleavingDist_self_shift_eq`, proved here) are in hand; only the `Quotient.lift`
well-definedness of `shiftQuot` and the action axioms remain — a direct descent argument
mirroring `quotDist`'s construction.

## Conjecture H (`IsoClass α` is a genuine `EMetricSpace`)
The lemmas `quotDist_self`, `quotDist_comm`, `quotDist_triangle`, and `quotDist_eq_zero_iff`
assemble into a full `PseudoEMetricSpace`/`EMetricSpace` instance on `IsoClass α` with
`edist = quotDist`, making Mathlib's entire extended-metric topology available for
persistence modules.
**The key insight is** that point separation (`quotDist_eq_zero_iff`) is precisely the
`eq_of_edist_eq_zero` field that upgrades a pseudo-extended-metric to an extended metric, and
the remaining structure fields accept Mathlib's `uniformSpaceOfEDist` defaults.
**Why now?** This cycle proved exactly the four `edist` axioms; instantiating
`EMetricSpace` is now a packaging step that immediately exports completeness/continuity
vocabulary to the interleaving world.

## Conjecture I (Rank descends to a 1-Lipschitz map of quotient metrics)
The rank functor `rankMod` (finite `β`) sends distance-zero classes to distance-zero classes
and therefore descends to `rankQuot : IsoClass (Set β) → IsoClass ℕ` that is **1-Lipschitz**
for the quotient metrics: `quotDist (rankQuot Q) (rankQuot Q') ≤ quotDist Q Q'`.
**The key insight is** that `rank_interleavingDist_le` already proves the contraction on
representatives, and contraction maps zero distance to zero distance, so the descent is
automatic via `Quotient.lift` exactly as `quotDist` itself was built.
**Why now?** The contraction `rank_interleavingDist_le` (catalog) and the descent toolkit
`interleavingDist_eq_of_dist_zero` / `quotDist` (this cycle) are both available; the missing
piece is a single `DistZero`-preservation lemma feeding `Quotient.lift`.

## Conjecture J (Tightness fails *exactly* for non-strictly-monotone modules)
The strict-monotonicity hypothesis in `interleavingDist_self_shift_eq` is **sharp and
characterising**: `interleavingDist M (shift c M) = ENNReal.ofReal c` holds *iff* `M` is not
eventually constant on every window of length `c`; for a module that is constant on some
interval of length `≥ c`, the distance is strictly `< ofReal c`.
**The key insight is** that the lower-bound proof `Interleaved.shift_lower_bound` consumed
strict monotonicity at a single interior witness point, so its failure (a flat window) is
exactly what lets a cheaper interleaving slip through — a constant window can be shifted for
free.
**Why now?** This cycle proved the `⇐` (tight) direction and the Critic already exhibited
the constant-module counterexample; the `⇒` boundary is the contrapositive of
`shift_lower_bound`, reusing the same evaluate-at-a-witness technique.
