# Future Directions: Tropical VC-Dimension from Arithmetic-Height Valuation Cells

## Synthesis

This cycle fused two previously disjoint catalog corners — the arithmetic-height
side of `Bridges/ArithmeticVCDimension.lean` (`ArithmeticVCDim.ratArithHeight`,
the Weil-style rational height) and the tropical-valuation side of
`Bridges/CategoricalTropicalUltrametric.lean` (`TropicalValuationObject`, the
`(R, max, +)` semiring) — into a single quantitative bridge to statistical learning
theory. The unifying object is the **tropical halfspace**
`v_i(x) + a ≤ v_j(x) + b`. The decisive move is a homotopy-flavored *normal form*:
every such halfspace deformation-retracts onto a single real difference observable
`g_{ij} = v_i - v_j`, collapsing a `d`-dimensional family of comparisons onto a
1-dimensional ordered cell complex. On a finite sample this complex is a **chain**
of nested traces, and the whole VC story falls out of counting the rungs of that
chain.

## Results Summary

All proofs are complete (`sorry = 0`, only `propext`/`Classical.choice`/`Quot.sound`)
in `Catalog/Bridges/TropicalVCDimension.lean`:

- `tropHalfspace_eq_threshold` — normal form: a tropical halfspace is exactly a
  threshold set of `tropDiff` at level `b - a`.
- `threshold_no_two_shatter` / `tropHalfspace_no_two_shatter` — VC dimension `≤ 1`:
  no two-point sample is shattered by a single threshold/halfspace family.
- `threshold_shatters_singleton` — VC dimension `≥ 1`: every one-point sample is
  shattered; together with the above, the VC dimension is *exactly* 1.
- `threshold_trace_card_le` / `tropHalfspace_trace_card_le` — sharp shatter bound:
  at most `n + 1` distinct traces on an `n`-point sample (chain/cardinality argument).
- `tropProduct_trace_card_le` — polynomial cell bound `(n+1)^k` for a concept class
  built from `k` valuation halfspaces: the intersection trace is a function of the
  tuple of coordinate traces, giving a product bound of degree `≤ k` in `n`.
- `ratHeight_le_finite` + `tropical_height_trace_bound` — Northcott-style finiteness
  certifies that height-bounded rational samples are finite, so the cell counts are
  over genuinely finite samples.

## Bold, Falsifiable Research Directions

### 1. Sauer–Shelah sharpening: from `(n+1)^k` to `O(n^{VC})`

The product bound `(n+1)^k` is honest but loose: classical Sauer–Shelah predicts the
shatter function is bounded by `∑_{i≤D} C(n,i)` where `D` is the *true* VC dimension
of the intersection class, which is `Θ(k)` rather than exactly `k`. **The key insight
is that the chain/cardinality injection used for a single observable can be upgraded
to a "trace-refinement" partial order on tuples, whose antichains — not its full
product — control the count.** Conjecture: `interTrace` realizes at most
`∑_{i=0}^{c·k} C(n,i)` distinct traces for an explicit constant `c`, and this is
tight up to `c`. Falsifiable: exhibit a `k`-halfspace family whose trace count
exceeds any such polynomial, or prove the refined bound. *Why now?* The `(n+1)^k`
scaffold and the chain lemma `threshold_trace_card_le` are already formalized, so the
combinatorial core (counting nested chains inside a product poset) is the only
missing piece — no new analytic infrastructure is required.

### 2. Coordinate-projection monotonicity as a forgetful functor

Dropping a valuation coordinate `feat x i` should only *decrease* shattering, since it
forgets distinctions. **The key insight is that coordinate projection is a forgetful
functor on tropical concept classes, and VC dimension / shatter functions are
contravariant lax-monotone invariants under it.** Conjecture: for the projection
`π : (Fin (d+1) → ℝ) → (Fin d → ℝ)`, the shatter function of the projected class is
pointwise `≤` that of the original, and VC dimension is monotone. Falsifiable: a
projection that *raises* the shatter count would refute it. *Why now?* `tropDiff`
and `interTrace` are already parameterized by the coordinate index set, so projection
is literally precomposition with a `Fin` map; the monotonicity reduces to a
`Finset.image`-card inequality of the same flavor already proven here.

### 3. Genuine `TropicalValuationObject` instantiation and reconstruction transfer

This cycle modeled valuations as `ℝ`-valued maps. **The key insight is that the
`(R, max, +)` axioms of `TropicalValuationObject` give an order-embedding into `ℝ` on
any finite sample, so the VC bounds proven over `ℝ` transfer *functorially* to
arbitrary tropical valuation objects via the reconstruction functor of
`CategoricalTropicalUltrametric`.** Conjecture: for any `TropObj` and any finite
sample, the order on `tropDiff`-analogues factors through a monotone map to `ℝ`,
making `threshold_trace_card_le` hold verbatim. Falsifiable: a tropical object whose
finite-sample order cannot be `ℝ`-embedded (e.g. a genuinely partial order) would
break the transfer. *Why now?* `TropicalValuationObject` already ships `le_total`
(linearity) and `max`-idempotence, exactly the hypotheses an order-embedding needs;
the bridge is one finite order-embedding lemma away.

### 4. Height-stratified codebook capacity and a pseudo-dimension thermometer

Combining `ratHeight_le_finite` with the trace bounds suggests a *capacity* statement:
the number of distinguishable tropical labelings achievable by height-`≤ N` rational
threshold parameters is simultaneously bounded by sample combinatorics `(n+1)^k` and
by parameter arithmetic `|{q : ratArithHeight q ≤ N}|`. **The key insight is that the
binding constraint switches at a critical height `N*(n,k)` — below it arithmetic
height caps capacity, above it sample geometry does — giving a phase transition in
effective pseudo-dimension.** Conjecture: there is an explicit `N*(n,k)` such that the
realized trace count equals `min(arithmetic capacity, (n+1)^k)` with the crossover at
`N*`. Falsifiable: measured capacity that beats both bounds, or a crossover at a
different order than predicted. *Why now?* Both bounding quantities are now
formalized as Lean theorems in the same file, so the `min` law and its crossover are
directly stateable and testable by `#eval` on small `(n,k,N)`.

### 5. Path-space / homotopy reading of the threshold chain

The traces `c ↦ trace S g c` form a monotone path in the Boolean lattice `2^S`,
i.e. a discrete monotone path in a cube. **The key insight is that the shatter bound
`n+1` is precisely the length of a maximal monotone lattice path, so VC dimension of a
threshold family is a *path-length* (1-dimensional homotopical) invariant of the cube,
and intersections of `k` halfspaces correspond to `k`-fold path products.** Conjecture:
the VC dimension of a tropical concept class equals the maximal length of a "monotone
multi-path" in `(2^S)^k` realizable by threshold tuples, recovering both the `≤ 1` and
`(n+1)^k` results as degenerate path counts. Falsifiable: a class whose VC dimension
diverges from any monotone-path length would refute the homotopical identification.
*Why now?* `trace_mono` already exhibits the path structure explicitly, and the
product construction `interTrace` is literally a `k`-fold path product — the
homotopical language is descriptive of objects already in the file.
