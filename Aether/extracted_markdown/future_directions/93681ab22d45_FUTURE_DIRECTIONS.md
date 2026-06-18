# Future Directions — Boltzmann Bridge VII: the Interleaving Distance is a *Metric*

## Synthesis

`Applications/BoltzmannBridge/InterleavingClosure.lean` discharges **Future
Direction 1** of Boltzmann Bridge VI and, in doing so, *overturns* the central
pessimistic claim that ran through Bridges V and VI.

Bridge V (`InterleavingMetric`) built the `ℝ≥0∞`-valued `eInterleavingDist` and
the pseudo-emetric `interleavingPseudoEMetric`, recording an "honest defect":
allegedly *distinct* filtrations could sit at extended interleaving distance `0`,
so the structure was "only a pseudometric". Bridge VI (`InterleavingQuotient`)
took that defect at face value and quotiented it away with Mathlib's universal
`SeparationQuotient`, obtaining a genuine `EMetricSpace` on the quotient and
characterising the kernel only as the *limiting* relation
`eInterleavingDist = 0 ↔ ∀ ε>0, ∃ δ<ε, Interleaved F G δ`
(`eInterleavingDist_eq_zero_iff`). It explicitly deferred the clean equivalence
`eInterleavingDist = 0 ↔ Interleaved F G 0` to "future work requiring closedness
of the witness set".

Bridge VII proves that closedness in one line of mathematics — and shows the
"defect" never existed:

1. **Closedness** (`interleaved_zero_of_forall_pos`): if `F, G` are
   `ε`-interleaved for *every* `ε > 0` then they are `0`-interleaved. The only
   input is the Archimedean squeeze `(∀ ε>0, a ≤ b+ε) → a ≤ b`
   (`le_of_forall_pos_le_add`) applied to the weights.
2. **Attained infimum** (`eInterleavingDist_eq_zero_iff_interleaved_zero`):
   combining (1) with Bridge VI's limiting characterisation and the upward
   monotonicity `Interleaved_mono` of Bridge IV gives
   `eInterleavingDist F G = 0 ↔ Interleaved F G 0`. The infimum is *attained*.
3. **T0 separation** (`eInterleavingDist_eq_zero_iff_eq`): `Interleaved F G 0`
   means the sublevel families coincide at every scale
   (`interleaved_zero_iff_sublevel_eq`) ⇔ equal weight functions
   (`interleaved_zero_iff_weight_eq`) ⇔ equal filtrations (`ext_weight`, by
   proof irrelevance on the non-data fields of `Filtration`). Hence
   `eInterleavingDist F G = 0 ↔ F = G`.
4. **Consequences**: `Filtration α` is *already* a genuine `EMetricSpace`
   (`interleavingEMetricDirect`); Bridge VI's `SeparationQuotient` map is
   *injective* (`mk_injective`, `mk_eq_mk_iff_eq`); and the converse Bridge VI
   declared to "fail in general" in fact *holds* (`mk_eq_mk_iff_interleaved_zero`).

The lesson is methodological: a *limiting* characterisation of a kernel
("distance 0 = arbitrarily tight interleavings") is weaker than an *algebraic*
one ("distance 0 = a literal 0-interleaving"), and the gap between them is
exactly an attained-infimum argument. Pushing the squeeze through collapsed the
entire pseudometric/quotient apparatus of two prior bridges.

## Results Summary

All theorems in `InterleavingClosure.lean` compile with `sorry`-count `0` and
depend only on `propext`, `Classical.choice`, `Quot.sound`.

| Theorem | Statement |
|---|---|
| `ext_weight` | a filtration is determined by its weight function |
| `interleaved_zero_iff_sublevel_eq` | `Interleaved F G 0 ↔ ∀ t, F.sublevelFaces t = G.sublevelFaces t` |
| `interleaved_zero_iff_weight_eq` | `Interleaved F G 0 ↔ F.weight = G.weight` |
| `interleaved_zero_of_forall_pos` | `(∀ ε>0, Interleaved F G ε) → Interleaved F G 0` |
| `eInterleavingDist_eq_zero_iff_interleaved_zero` | the infimum is attained |
| `eInterleavingDist_eq_zero_iff_eq` | **distance `0` ⇔ equality** |
| `interleavingEMetricDirect` | genuine `EMetricSpace (Filtration α)` |
| `mk_injective`, `mk_eq_mk_iff_eq`, `mk_eq_mk_iff_interleaved_zero` | the Bridge VI quotient is trivial |

## Falsifiable Research Directions

### Direction 1 — The interleaving distance *is* the sup-distance of weights

**Conjecture.** For all `F G : Filtration α`,
`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`
(the extended sup-norm distance of the weight functions); equivalently, on
filtrations with bounded weight-gap, `interleavingDist F G = sSup {|F.weight σ -
G.weight σ| : σ}`. This would upgrade `eInterleavingDist_le_supDist` (Bridge V,
one inequality) to an *equality* and exhibit `Filtration α` as isometric to a
subspace of `(Finset α → ℝ, sup-norm)`.

The key insight is that Bridge VII proved the defining infimum is *attained* at a
literal `0`-interleaving exactly when weights are equal; the same attained-infimum
machinery should pin the value of the infimum in general, because `stability_supDist`
already shows every weight-gap bound `D` yields a `D`-interleaving, and the reverse
("an interleaving forces a weight-gap bound") is the contrapositive of the
sublevel-membership argument used in `interleaved_zero_iff_weight_eq`.

Why now? With T0 separation established, the remaining content is purely
quantitative, and both inequalities already have half-proofs in the arc
(`eInterleavingDist_le_supDist` one way, the membership squeeze the other) — the
conjecture is a sharp, immediately testable equality with a clear falsifier (any
filtration pair whose interleaving distance strictly undercuts the sup-gap).

### Direction 2 — Where the collapse *fails*: non-Archimedean weights

**Conjecture.** Replace the codomain `ℝ` of `Filtration.weight` by an ordered
field/monoid `W` that is **not** densely ordered or not Archimedean (e.g. the
tropical/min-plus semiring of `Catalog/Tropical/MinPlusAlgebra.lean`, or an
ultrametric value group as in
`Catalog/Speculative/AutoResearch/TropicalUltrametricBridge.lean`). Then
`interleaved_zero_of_forall_pos` becomes **false**: there exist distinct
`W`-filtrations `F ≠ G` with `eInterleavingDist F G = 0`, so the separation
quotient of Bridge VI is genuinely non-trivial and the `EMetricSpace` of Bridge
VII degenerates back to a pseudometric.

The key insight is that the *entire* T0 collapse of Bridge VII rests on the single
Archimedean fact `le_of_forall_pos_le_add`, which is exactly what a non-densely-
ordered or non-Archimedean `W` denies — so the kernel is an invariant measuring
the *order-theoretic completeness* of the weight space, not of the topology.

Why now? Bridge VII isolates the unique load-bearing hypothesis to a named one-line
lemma, making it surgically removable; and the catalog already contains both the
tropical and ultrametric scaffolding to instantiate `W`, so the cross-domain
counterexample is constructible today and falsifiable by a single explicit pair.

### Direction 3 — Functoriality and 1-Lipschitz pushforward

**Conjecture.** A weight-nonincreasing map of vertex sets `f : α → β` (or a
simplicial map) induces a pushforward `f# : Filtration α → Filtration β` that is
**1-Lipschitz** for `eInterleavingDist`, i.e.
`eInterleavingDist (f# F) (f# G) ≤ eInterleavingDist F G`, making
`F ↦ (Filtration, eInterleavingDist)` a functor into the category of extended
metric spaces and short maps.

The key insight is that `Interleaved_trans`/`Interleaved_mono` already make
interleaving a graded preorder closed under composition, and Bridge VII's attained
infimum lets one transport a witnessing `0`- or `δ`-interleaving *through* `f#`
without an approximation argument, so Lipschitz-ness reduces to monotonicity
bookkeeping on sublevel sets.

Why now? Functoriality was impossible to state cleanly while the structure was only
a pseudometric with an opaque kernel; with a genuine `EMetricSpace` on `Filtration α`
itself (no quotient), "short map" is now a literal Mathlib property
(`LipschitzWith 1`) that can be discharged directly.

### Direction 4 — Completeness of the interleaving emetric space

**Conjecture.** `(Filtration α, eInterleavingDist)` is a **complete** extended
metric space: every Cauchy sequence of filtrations converges, with the limit
filtration's weight the pointwise limit of the weights. Consequently the metric
of Bridge VII is not merely T0 but a Polish-type completion target.

The key insight is that Bridge VII's `eInterleavingDist_eq_zero_iff_eq` identifies
the metric with a weight-space metric (Direction 1), and pointwise/uniform limits
of monotone weight functions are again monotone — so completeness of the weight
sup-metric should transfer to completeness of the filtration emetric verbatim.

Why now? Completeness only becomes a meaningful (non-vacuous) question once points
are separated; before Bridge VII the "space" had indistinguishable points and the
notion of a unique limit was ill-posed.

### Direction 5 — Quantitative stability is an isometric embedding of data

**Conjecture.** The Vietoris–Rips assignment `d ↦ diamFiltrationOf d` from
distance matrices `(α → α → ℝ, sup-norm)` to `(Filtration α, eInterleavingDist)`
is itself **1-Lipschitz and, on symmetric hollow matrices, an isometry**:
`eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
   = ENNReal.ofReal (⨆ x y, |d₁ x y - d₂ x y|)`. This sharpens `vr_eStability`
(Bridge V, the `≤` direction) to an equality and makes the persistence pipeline a
*distortion-preserving* embedding rather than a mere contraction.

The key insight is that `diamWeightOf_dist_le` (Bridge IV) already gives the `≤`
direction with a matching constant `1`, and Bridge VII's attained-infimum result
removes the only obstruction to the reverse inequality, namely the fear that the
interleaving infimum could be strictly smaller than any realised weight gap.

Why now? The forward stability bound and the attained infimum are both in hand;
the conjecture is the precise statement that "stability is tight", with an explicit
falsifier available from small point clouds such as the `cloud₁`/`cloud₂` pair
already certified in `BottleneckStability.lean`.
