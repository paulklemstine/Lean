# Future Directions — Height-controlled tropical separation via arithmetic VC cells

## Synthesis

The new file `Catalog/Bridges/HeightTropicalSeparation.lean` closes a concrete
bridge between three previously separate catalog domains: arithmetic height
(`Bridges/ArithmeticVCDimension.lean`), tropical valuation structure
(`Bridges/CategoricalTropicalUltrametric.lean`), and valuation depth
(`Computation/PadicValuationDepth.lean`). The organizing idea is the
*arithmetic valuation cell*: the pairwise `≤`-comparison pattern
(`tropSignature`) of the `k` rational forms of a tropical threshold system at a
point. Because tropical addition is `max`, every behaviorally relevant fact
about a point is contained in this finite signature, so a *cell-factored*
classifier (a readout of the signature) sees the feature space only through a
space of at most `2 ^ (k*k)` cells.

## Results summary (all proven, `sorry`-free, axioms = propext/Classical.choice/Quot.sound)

- `shatters_iff_injective_tropSignature` — the full readout family shatters a
  sample **iff** the cell map is injective on it. This is the structural heart:
  shattering is exactly an injectivity (separation) statement, not a counting
  estimate.
- `card_le_cellBound_of_shatters` / `not_shatters_of_card_gt_cellBound` /
  `boolVCDim_readoutFamily_le` — an explicit, geometry-free VC bound:
  `VCdim ≤ 2 ^ (k*k)`. No sample larger than the cell count can be shattered.
- `boolVCDim_appendForms_le` — compositional closure: concatenating a `k`-term
  and an `m`-term system yields the bound `2 ^ ((k+m)*(k+m))`.
- `vdepth_sum_range_le` — valuation-depth closure generalizing the catalog
  two-term `vdepth_sum_le` to arbitrary arity: an `m`-fold combination of
  depth-`≤D` terms has depth `≤ D + m`.
- `finite_boundedHeightVec` — Northcott-style finiteness: only finitely many
  height-`≤H` coefficient vectors exist, the arithmetic source of finitely many
  distinct systems.

The honest boundary discovered: the *cell* bound is governed by `k` alone;
arithmetic height `H` does not tighten it in the worst case. Height instead
controls the **number of distinct systems** (finiteness), and depth `d` controls
**compositional cost**. The conjectures below test whether `H` and `d` can be
made to genuinely sharpen capacity, not just count systems.

---

## Direction 1 — A Sauer–Shelah refinement: polynomial, not exponential, growth

The current bound `2 ^ (k*k)` counts *all* signatures, but the realizable cells
of `k` rational forms are an arrangement-like structure and should be far fewer.
Conjecture: for `k` affine forms `forms i x = c i + g i x` over a `1`-dimensional
feature, the number of realizable cells over any sample is `O(k^2)`, giving
`VCdim = O(k^2)` rather than `2^(k*k)`.

The key insight is that two points share a cell unless some pair of forms swaps
order between them, and order swaps of `k` affine functions on a line occur at
most `binom(k,2)` times, so the realizable-cell count is linear-in-sample and
quadratic-in-`k`. This is falsifiable: exhibit `k` forms and a sample forcing
super-quadratically many distinct realized signatures, or prove the `O(k^2)`
ceiling. Why now? The `shatters_iff_injective_tropSignature` characterization
already reduces the whole question to counting *realized* signatures, so the
remaining work is a pure arrangement-counting lemma with no learning theory left
to formalize.

## Direction 2 — Height as a genuine capacity parameter via cell coarsening

Conjecture: if all coefficients have arithmetic height `≤ H`, then over any
sample whose feature values also have height `≤ H`, the number of *distinct
realized* cells is bounded by an explicit function `N(H,k)` that is independent
of sample size and grows polynomially in `H`. This would upgrade the present
"height ⇒ finitely many systems" statement to "height ⇒ uniformly bounded
capacity per system".

The key insight is that with bounded height the forms can cross only at rationals
of bounded height (a Northcott constraint on intersection points), so the number
of order-change loci — hence cells — is itself height-bounded. Falsifiable:
either prove `N(H,k)` exists and is sample-independent, or build a height-`H`
family realizing unboundedly many cells as the sample grows. Why now?
`finite_boundedHeightVec` and `ratHeight_pos` already give the finiteness
scaffolding; the missing piece is a height bound on crossing points, which is a
self-contained Diophantine lemma.

## Direction 3 — Depth-graded compositional capacity

`vdepth_sum_range_le` shows depth grows additively under iterated tropical
combination. Conjecture: VC capacity and valuation depth satisfy a joint law of
the form `VCdim(combine f₁ … f_m) ≤ Φ(d) · (Σ kᵢ)²`, where `d` bounds each term's
valuation depth, so that *depth-bounded* compositions have capacity growing only
polynomially in total arity even though naive concatenation gives
`2 ^ ((Σ kᵢ)²)`.

The key insight is that bounded valuation depth restricts how finely composed
forms can subdivide cells: each unit of depth can at most square the number of
sign distinctions, so a depth-`d` budget caps cell refinement at a `Φ(d)` factor
rather than the free-composition blow-up. Falsifiable: pin down `Φ` and prove the
joint bound, or find depth-`d` compositions whose realized-cell count beats every
polynomial in arity. Why now? The depth API (`vdepth_add`, `vdepth_mul`,
`vdepth_sum_range_le`) is now available at arbitrary arity, so the inductive step
needed to track cell refinement against depth can be stated directly.

## Direction 4 — Argmax (multiclass tropical) classifiers

The present readouts are binary. The natural tropical classifier is the
*argmax*: label `x` by which form attains `max_j (forms j x)`. Conjecture: the
argmax family over `k` forms has multiclass capacity (Natarajan/graph dimension)
exactly `Θ(k)`, and the binary one-vs-rest reductions all factor through the same
`tropSignature`.

The key insight is that the argmax is a *function of the cell* — it is literally
read off the top of the `tropSignature` preorder — so the entire multiclass
theory inherits the injectivity characterization already proven for the binary
case, with the cell space unchanged. Falsifiable: prove the `Θ(k)` Natarajan
bound through `tropSignature`, or exhibit an argmax family whose multiclass
dimension exceeds any linear function of `k`. Why now? `tropClassifier` and
`readoutFamily` are defined as readouts of the signature, so an argmax readout is
a one-line specialization and the separation machinery transfers verbatim.

## Direction 5 — From `ℚ` to a general `TropicalValuationObject`

The forms here are `ℚ`-valued; the catalog's `TropicalValuationObject` provides
an abstract ordered idempotent semiring with `add = max`. Conjecture: the entire
separation theorem (`shatters_iff_injective_tropSignature` and the
`2^(k*k)` bound) holds verbatim for forms valued in any
`TropicalValuationObject` with a decidable total order, with the cell space again
`Fin k → Fin k → Bool`.

The key insight is that the proof never uses any property of `ℚ` beyond a
decidable linear order, so the only obstruction is supplying `Decidable (trop.le
a b)` and reproving `tropSignature` injectivity in the abstract setting — the
combinatorics is order-theoretic, not arithmetic. Falsifiable: either generalize
the file to `TropicalValuationObject` and keep all proofs, or identify an
order-theoretic axiom genuinely required that `TropicalValuationObject` lacks.
Why now? The abstract object and its `le_total`/`le_antisymm` axioms already
exist in `Bridges/CategoricalTropicalUltrametric.lean`, so the generalization is
a direct re-typing of the existing, now-proven, argument.
