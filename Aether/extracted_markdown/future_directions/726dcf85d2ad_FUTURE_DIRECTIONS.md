# FUTURE DIRECTIONS — Functorial tropical lower bounds for code minimum distance via metric filtrations

This cycle established a reusable bridge between the catalog's *metric-filtration* layer
(`PoincareData/MetricFiltration.lean`: `ripsGraph`, `ripsGraph_mono`) and its
*smooth-Poincaré coding* layer (`SmoothPoincare/TopologicalCodes.lean`: `wt`, `overlap`,
`ip`, `wt_add_overlap`).  The new files are:

* `PoincareData/CodeMetricFiltration.lean` — codewords as points of the Hamming metric
  space `HCode n`; the overlap-controls-distance identity
  `hammingDist_add_two_overlap`; the monotone edgelessness certificate
  (`ripsEdgeless_antitone`, from `ripsGraph_mono`); the minimum-distance lower bound
  certificate (`minWeight_ge_of_ripsEdgeless_nat`); and the geometric recovery of the
  `[8,4,4]` minimum distance of the extended Hamming code
  (`hamming_minDist_via_filtration`).
* `PoincareData/CodeDirectSum.lean` — metric functoriality (`hammingDist_append`) and
  functoriality of the certificate under direct sums (`directSum_minWeight_lower`,
  sharp by `directSum_minWeight_sharp`).

The findings below are falsifiable conjectures the next cycle can attack directly.

## Conjecture 1 — The Rips threshold equals the minimum distance, exactly

For a linear code `C` with `0 ∈ C`, define the **Rips threshold**
`ρ(C) = sInf { ε : 0 ≤ ε ∧ ¬ RipsEdgeless C ε }`.  Then `ρ(C)` equals the Hamming
minimum distance `d(C)` (the minimum nonzero weight), as a real number.

*The key insight is* that `minWeight_lower_of_ripsEdgeless` and `ripsEdgeless_of_minDist`
are already two halves of an `Iff`; promoting them to an equality of a real infimum only
requires packaging the discrete weight spectrum as the jump set of the monotone
filtration `ε ↦ ripsGraph (HCode n) ε`.

*Why now?* The monotonicity (`ripsEdgeless_antitone`) and both inequality directions are
formalized and `sorry`-free in this cycle; the remaining step is purely an `sInf`/`csInf`
computation over a finite jump set, which Mathlib's order API supports.

## Conjecture 2 — Persistent π₀ of a self-dual code detects double-evenness

For a binary self-dual code `C`, the first scale at which the induced Rips graph on `C`
acquires an edge is divisible by `4` **iff** `C` is doubly even; for merely self-dual
codes it is divisible by `2`.

*The key insight is* that `selfDual_even_weight` forces all weights even and
`hamming_doublyEven` forces them divisible by `4`, so the *gaps* in the weight spectrum —
equivalently, the scales at which `ripsGraph` edges first appear — inherit the same
divisibility; the filtration thus *reads off* the evenness class geometrically.

*Why now?* `hammingDist_add_two_overlap` ties the edge scales directly to `overlap`, and
the evenness theorems `selfDual_even_weight` / `doublyEven_selfOrthogonal` are already in
the catalog; only the divisibility-of-threshold statement remains.

## Conjecture 3 — A Singleton-type ceiling from covering numbers

For a length-`n` binary code `C` with `|C|` codewords, the metric-filtration covering
number `coveringNumber C ε` (already defined in `MetricFiltration.lean`) yields a lower
bound on `|C|` that, combined with `minWeight_ge_of_ripsEdgeless_nat`, reproduces a
Singleton-type inequality `d(C) ≤ n − log₂ |C| + 1`.

*The key insight is* that `coveringNumber_antitone` and the Rips threshold both measure
the same scale-dependent connectivity, so a packing/covering duality
(`maximal_packing_is_cover`) converts the distance certificate into a cardinality bound.

*Why now?* The covering-number API (`coveringNumber_le_card`, `coveringNumber_antitone`,
`maximal_packing_is_cover`) is fully proved in the metric layer and was previously
disconnected from the coding layer; this cycle's bridge makes the two comparable.

## Conjecture 4 — Tensor (Kronecker) products multiply the certificate

For codes `C, D` with certified minimum weights `a, b`, the tensor product code
`C ⊗ D` (codewords are rank-one matrices `xᵀy`) satisfies the multiplicative certificate
`d(C ⊗ D) = a · b`, with a metric-filtration proof mirroring the additive
`directSum_minWeight_lower`.

*The key insight is* that the Hamming weight of a tensor `xᵀy` is exactly `wt x · wt y`,
so the additive functoriality `hammingDist_append` upgrades to a multiplicative one once
concatenation is replaced by the product index `Fin n × Fin m`.

*Why now?* `directSum_minWeight_lower` shows the certificate is monoidal under `⊕`; the
only new ingredient for `⊗` is a weight-multiplicativity lemma, structurally identical to
the `wt_append` proof via `Fintype.sum` splitting.

## Conjecture 5 — Rank-16 separation: `E8 ⊕ E8` vs `D16⁺` at the filtration level

The two even unimodular rank-16 forms give two doubly-even self-dual `[16,8]` codes whose
Rips filtrations have *identical* π₀ thresholds (both minimum distance `4`) but
*different* weight enumerators; the filtration certificate alone cannot separate them,
whereas a persistent-`H₁` refinement can.

*The key insight is* that minimum distance (a π₀/threshold invariant) is blind to the
`E8⊕E8` vs `D16⁺` distinction — exactly the catalog's lattice-side observation that both
clear Rokhlin but only one story needs higher invariants — so the separation must live in
`H₁` of the Rips complex, not its `1`-skeleton.

*Why now?* This cycle pins the π₀/threshold invariant precisely
(`minWeight_ge_of_ripsEdgeless_nat`), making it concrete which information the
`1`-skeleton *cannot* see, and thereby motivating the first genuinely homological
(`H₁`) extension of the metric-filtration layer.
