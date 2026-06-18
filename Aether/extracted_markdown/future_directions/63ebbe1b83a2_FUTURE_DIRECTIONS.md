# Future Directions — The Interleaving Metric Quotient (Boltzmann Bridge VI)

## Synthesis

`Applications/BoltzmannBridge/InterleavingQuotient.lean` discharges **Future
Direction 1** of Boltzmann Bridge V. Bridge V had moved the interleaving distance
into the `ℝ≥0∞` codomain, obtaining a genuine `PseudoEMetricSpace (Filtration α)`
(`interleavingPseudoEMetric`) but leaving an honest defect: distinct filtrations
can sit at extended distance `0`, so the structure was only a *pseudo*metric.

Bridge VI removes that defect categorically. Instead of hand-building a quotient,
we observe that `eInterleavingDist` already satisfies the pseudo-emetric axioms,
so Mathlib's `SeparationQuotient` functor manufactures a true `EMetricSpace`
(`interleavingEMetric`) for free, with the canonical map an **isometry**
(`edist_quotient_mk`). The kernel of the quotient is described intrinsically:
two filtrations are identified **iff** their extended interleaving distance is `0`
(`mk_eq_mk_iff_eInterleavingDist_zero`), and this in turn holds **iff** there are
admissible interleavings of arbitrarily small magnitude
(`eInterleavingDist_eq_zero_iff`). A literal `0`-interleaving is sufficient but,
in general, not necessary (`mk_eq_mk_of_interleaved_zero`).

The whole arc — II `HigherPersistence` → III `PersistenceStability` →
IV `BottleneckStability` → V `InterleavingMetric` → VI `InterleavingQuotient` —
collapses one slogan: *persistence stability is the metric shadow of the
relational `Interleaved_trans`, and the metric/pseudo-metric/true-metric ladder is
climbed purely by changing codomains and applying the universal
`SeparationQuotient` reflection.*

## Results summary

* `edist_quotient_mk` — `SeparationQuotient.mk` is an isometry for `eInterleavingDist`.
* `interleavingEMetric` — the genuine `EMetricSpace` on `SeparationQuotient (Filtration α)`.
* `mk_eq_mk_iff_eInterleavingDist_zero` — the metric kernel equals the distance-`0` relation.
* `eInterleavingDist_eq_zero_iff` — distance `0` ⇔ arbitrarily small interleavings.
* `mk_eq_mk_of_interleaved_zero` — a `0`-interleaving identifies in the quotient.

All four `Prop`-valued results depend only on `propext`, `Classical.choice`, and
`Quot.sound`.

## Research directions

### 1. Attainment of the interleaving infimum (closedness of the witness set)

`mk_eq_mk_of_interleaved_zero` is one-directional precisely because the infimum
defining `eInterleavingDist` need not be attained: distance `0` guarantees only
arbitrarily small interleavings, not a literal `0`-interleaving. **Conjecture:**
the witness set `{δ | Interleaved F G δ}` is closed in `ℝ` (it is an up-set by
`Interleaved_mono`, so closedness is equivalent to attainment of its infimum
`interleavingDist F G`), hence whenever it is nonempty the infimum is realised and
`eInterleavingDist F G = 0 ↔ Interleaved F G 0`. The key insight is that
`Interleaved F G δ` is an intersection over all scales `t` of the *closed*
conditions `F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)`, and set-inclusion of
sublevel families varies upper-semicontinuously in `δ` because `sublevelFaces` is
monotone and right-continuous in the scale. Why now? Bridge VI has reduced the
entire identification question to this single topological property of one subset
of `ℝ`; proving it would upgrade `eInterleavingDist_eq_zero_iff` from a limiting
characterisation to a clean algebraic one and make the quotient kernel decidable
from a single `δ = 0` test.

### 2. The quotient is a complete metric space

`SeparationQuotient` of a `PseudoEMetricSpace` is an `EMetricSpace`, but Bridge VI
says nothing about **completeness**. **Conjecture:** when the vertex type `α` is
finite, `SeparationQuotient (Filtration α)` with `interleavingEMetric` is a
complete `EMetricSpace`; every Cauchy sequence of filtration classes converges to
a class whose representative is the scale-wise limit of sublevel families. The key
insight is that, for finite `α`, each `Filtration α` is determined by finitely
many monotone weight functions `Finset α → ℝ`, so a Cauchy sequence in the
interleaving metric is a uniformly-Cauchy sequence of monotone weights, and the
pointwise limit of monotone functions is monotone — giving a limiting filtration
inside the same space. Why now? With the metric quotient finally in hand
(Bridge VI), completeness is the next structural invariant a metric geometer asks
for, and it is exactly the hypothesis needed to run fixed-point / persistence-
landscape arguments on the quotient.

### 3. Functoriality: `1`-Lipschitz pushforward along maps of data

Bridge IV proved stability for a *fixed* vertex set under perturbing the distance
matrix. **Conjecture:** a map `f : α → β` of vertex sets induces a
**`1`-Lipschitz** map between interleaving metric quotients, so that
`eInterleavingDist (pushforward f F) (pushforward f G) ≤ eInterleavingDist F G`,
and hence a well-defined contraction on the `SeparationQuotient`s. The key insight
is that pulling a distance matrix back along `f` can only *merge* vertices and thus
*shrink* every simplex diameter spread, which is the functorial form of the single
load-bearing estimate `diamWeightOf_dist_le`. Why now? Bridge VI gives the
*objects* (metric quotients); the obvious next layer is the *morphisms*, turning
the persistence pipeline into an honest functor
`(finite data, distortion) ⟶ (complete metric spaces, 1-Lipschitz)`.

### 4. Diameter / boundedness dichotomy of a connected component

In the pseudo-emetric, two filtrations are at distance `⊤` exactly when they are
*never* interleaved (empty witness set). **Conjecture:** the relation "finite
interleaving distance" partitions `Filtration α` into classes that become the
connected components of the metric quotient, and on each component the metric is
bounded iff the components' weight functions are uniformly comparable. The key
insight is that `Interleaved_trans` makes "finite distance" an equivalence
relation whose classes are precisely the `⊤`-free blocks of the extended metric,
so the quotient is an `ℝ≥0∞`-metric coproduct of genuine bounded metric pieces.
Why now? Bridge VI exposed `⊤` as a first-class value (the empty-witness case);
understanding its global geometry (which classes are `⊤` apart) is the natural
follow-up and connects to bottleneck-distance stratification in TDA.

### 5. The quotient metric refines the persistence-diagram bottleneck distance

The classical Cohen–Steiner–Edelsbrunner–Harer theorem compares *persistence
diagrams* under the bottleneck distance. **Conjecture:** there is a
`1`-Lipschitz map from the interleaving metric quotient
`SeparationQuotient (Filtration α)` to the space of persistence diagrams with the
bottleneck metric, factoring the CESH stability bound `eInterleavingDist_le_supDist`
through `interleavingEMetric`. The key insight is that the distance-`0` kernel
quotiented out in Bridge VI is *contained in* the kernel of the diagram map (two
filtrations with the same sublevel families at every scale have identical
diagrams), so the diagram map descends to the quotient and is automatically
`1`-Lipschitz there. Why now? With the metric quotient constructed, the long-
standing goal of the whole arc — recovering the literal bottleneck-stability
theorem of TDA as a quotient morphism — is finally a well-posed Lean statement
rather than an informal aspiration.
