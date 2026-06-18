# Future Directions — Metric Monotonicity & Local-to-Global Certificates for Vietoris–Rips Filtrations

Conjectures generated from this cycle (`RipsLocalToGlobal.lean`, building on `MetricFiltration.lean`
and `Bridges/CategoricalTropicalUltrametric.lean`). Each is intended to be precise and
Lean-formalizable.

## C1 — Ultrametric ⟺ reachability collapse (converse of the headline theorem)
We proved that `IsUltrametricDist α` implies `(ripsGraph α ε).Reachable x y ↔ dist x y ≤ ε`
for `0 ≤ ε`. **Conjecture:** the converse holds. If for *every* `ε ≥ 0` and all `x y`,
Rips-reachability at scale ε implies `dist x y ≤ ε`, then `dist` is an ultrametric.
Testable corollary: a single failure of the strong triangle inequality produces an ε and an
ε-chain certifying reachability beyond ε (the `rips_metric_reachable_gt` pattern, generalized).

## C2 — Quantitative Rips diameter bound for chains in general metric spaces
For a *general* `PseudoMetricSpace`, an ε-chain of length `n` (n edges) gives endpoints with
`dist ≤ n · ε`. **Conjecture:** `rips_walk_dist` generalizes to
`dist x y ≤ (w.length) * ε` for any Rips walk `w` at scale ε, and the bound is tight on ℝ.
This interpolates between the ultrametric collapse (effective length 1) and the linear metric
growth, and would quantify the "persistence resolution" of H₀.

## C3 — Two-sided metric-entropy sandwich and a Poincaré-threshold scaling law
We established `packingNumber S (2ε) ≤ coveringNumber S ε ≤ packingNumber S ε` (the right
inequality is the natural companion still to be formalized, via `maximal_packing_is_cover`).
**Conjecture:** for a doubling metric space of doubling dimension `d`, both quantities scale as
`Θ(ε^{-d})`, and the resulting critical scale where `ripsGraph` becomes connected obeys the
`n^{-1/d}` "Poincaré threshold" referenced in `MetricFiltration.lean`. Formalize the lower
bound `coveringNumber ≥ c · ε^{-d}` from a packing construction.

## C4 — π₀ stability under Gromov–Hausdorff / Hausdorff perturbation
Combine `sphere_perturbation_stability` with `rips_reachable_mono`. **Conjecture:** if two
finite point clouds are δ-close (each point of one within δ of the other and vice versa), then
their Rips π₀ partitions interleave: reachability at scale ε in one implies reachability at
scale `ε + 2δ` in the other. This is the H₀ shadow of the persistence stability theorem and
should be provable purely from the chain/monotonicity certificates of this file.

## C5 — Functorial transfer of the ultrametric collapse to the tropical bridge
`Bridges/CategoricalTropicalUltrametric.lean` reconstructs an ultrametric seminorm from
tropical valuation data. **Conjecture:** under that reconstruction functor, the Rips
filtration's π₀ relation is *exactly* the kernel-by-level of the tropical valuation, so
`rips_ultrametric_reachable_iff` becomes a statement about valuation level sets, and tropical
bounds transfer to Rips-connectivity certificates functorially. Target lemma: the Rips
π₀ equivalence at scale ε equals `{(x,y) | val(x - y) ≥ -log ε}` on the reconstructed space.
