# Summary of changes for run d27c083f-df9e-4293-986e-bb075b5a15d5
Extended the Baker–Norine graph Riemann–Roch development in `Catalog/Bridges/GraphRiemannRoch.lean` with a new, fully-proved `BakerNorineBounds` section. The existing file set up divisors, chip-firing, linear equivalence, the canonical divisor and the *statement* of Riemann–Roch, but proved none of the rank inequalities; this cycle fills that gap.

New definitions:
- `Winnable G D` — `D` is linearly equivalent to an effective divisor (the condition `r(D) ≥ 0`).
- `chips v₀ k` — the divisor placing `k` chips at one vertex.

New theorems (all proved, no `sorry`, depending only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`):
- `effective_add`, `degree_chips`, `effective_chips` — basic algebra of effective/point divisors.
- `linearEquiv_add_right` — translation-invariance of linear equivalence.
- `linearEquiv_trans` — transitivity of linear equivalence.
- `winnable_add_effective` — winnability is stable under adding an effective divisor (the engine for monotonicity).
- `hasRankAtLeast_zero_iff` — `HasRankAtLeast G D 0 ↔ Winnable G D`.
- `hasRankAtLeast_mono` — monotonicity of the Baker–Norine rank: rank `≥ r` implies rank `≥ s` for every `s ≤ r`.
- `hasRankAtLeast_le_degree` — the Riemann inequality `r(D) ≤ deg D`, one half of Riemann–Roch, proved from chip-firing degree conservation.
- `negative_degree_rank_neg` — corollary: a negative-degree divisor has rank `−1`.

These hold for an arbitrary finite simple graph with no connectivity or completeness hypothesis. Each theorem carries a brief proof-sketch comment, and a worked `example` shows the zero divisor is winnable. The whole file builds successfully (verified via the `Catalog` Lean project) and contains no remaining `sorry`.

Also added `FUTURE_DIRECTIONS.md` with five falsifiable research directions building on these results (the full Riemann–Roch equality via reduced divisors, Dhar's burning algorithm and uniqueness, a computable decidable rank function, Clifford's theorem for graphs, and gonality of complete graphs), each with a "key insight" and a "why now" justification tied to the lemmas proved this cycle.