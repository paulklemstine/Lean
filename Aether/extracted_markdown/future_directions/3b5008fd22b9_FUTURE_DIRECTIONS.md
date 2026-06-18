# Future Directions — Boltzmann Bridge VIII: Persistence is an *Isometry*

## Synthesis

`Applications/BoltzmannBridge/InterleavingIsometry.lean` discharges **Future
Direction 1** of Boltzmann Bridge VII (`InterleavingClosure`) and closes the
metric theory of the whole persistence-stability arc into a single closed form.

Bridge V (`InterleavingMetric`) proved only *one* inequality:
`eInterleavingDist_le_supDist`, "a uniform weight-gap bound `D` forces interleaving
distance `≤ ofReal D`" — persistence is `1`-Lipschitz in the data. Bridge VII
(`InterleavingClosure`) proved the *boundary* case, `eInterleavingDist F G = 0 ↔
F = G`, by showing `0`-interleaving is exactly equality of weight functions
(`interleaved_zero_iff_weight_eq`) and that the defining infimum is *attained* at
`0`. Bridge VIII shows that the boundary case is the shadow of a fully
quantitative phenomenon: the infimum is attained at *every* scale.

The single new engine is `interleaved_iff_weightCloseBy`:

> `Interleaved F G δ ↔ 0 ≤ δ ∧ ∀ σ, |F.weight σ - G.weight σ| ≤ δ`.

This is the exact converse of `stability_supDist` (Bridge IV), proved by
evaluating the two sublevel inclusions of an interleaving at the two birth times
`t = F.weight σ` and `t = G.weight σ`. At `δ = 0` it specialises to Bridge VII's
`interleaved_zero_iff_weight_eq`, so Bridge VIII genuinely *generalises* Bridge VII
rather than reproving it. With this characterisation the defining infimum of
`eInterleavingDist` becomes an infimum of sup-norm bounds, and the two duality
halves —

* `weightSupEDist_le_eInterleavingDist` (every witness `δ` dominates every weight
  gap, so the `⨆` of gaps is below the `⨅` of witnesses), and
* `eInterleavingDist_le_weightSupEDist` (the attained-infimum argument: when the
  `⨆` of gaps is finite, its real value `c.toReal` is itself an admissible shift
  via `stability_supDist`) —

combine to the **isometry formula**

> **`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`**
> (`eInterleavingDist_eq_weightSupEDist`).

As a one-line corollary, Bridge VII's T0 separation `weightSupEDist F G = 0 ↔ F = G`
(`weightSupEDist_eq_zero_iff_eq`) falls out of the formula. The methodological
lesson sharpens Bridge VII's: an *attained* infimum is not just enough to separate
points — it pins the *entire* metric to a closed sup-norm form. Persistence is an
isometry, not merely a contraction.

## Results Summary

All theorems in `InterleavingIsometry.lean` compile with `sorry`-count `0` and
depend only on `propext`, `Classical.choice`, `Quot.sound`.

| Theorem | Statement |
|---|---|
| `interleaved_iff_weightCloseBy` | `Interleaved F G δ ↔ 0 ≤ δ ∧ ∀ σ, \|F.weight σ − G.weight σ\| ≤ δ` |
| `weightSupEDist` | the extended sup-distance `⨆ σ, ENNReal.ofReal \|F.weight σ − G.weight σ\|` |
| `weightSupEDist_le_eInterleavingDist` | the `≥` half of the isometry |
| `eInterleavingDist_le_weightSupEDist` | the `≤` half (attained infimum) |
| `eInterleavingDist_eq_weightSupEDist` | **the isometry formula** |
| `weightSupEDist_eq_zero_iff_eq` | T0 separation recovered from the formula |

## Falsifiable Research Directions

### Direction 1 — Vietoris–Rips stability is *tight*: an entrywise isometry

**Conjecture.** For symmetric, hollow distance matrices `d₁ d₂ : α → α → ℝ` over a
finite vertex type,
`eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
   = ⨆ x, ⨆ y, ENNReal.ofReal |d₁ x y − d₂ x y|`.
That is, the simplex-indexed sup `⨆ σ` of Bridge VIII collapses to an
*edge-indexed* sup, sharpening `vr_eStability` (Bridge V, the `≤` direction) to an
equality and making the VR functor a distortion-preserving embedding of distance
matrices.

The key insight is that Bridge VIII already reduces the left side to
`⨆ σ, ENNReal.ofReal |diamWeightOf d₁ σ − diamWeightOf d₂ σ|`, and `diamWeightOf`
is a finite `sup'` over the vertex pairs of `σ`; the gap of two `sup'`s is bounded
by the worst single pair (`diamWeightOf_dist_le` gives `≤`, and the pair attaining
`diamWeightOf d₁ σ` realises the reverse), so the whole equality is a finite
`sup'`-vs-`sup'` extremal-pair argument with no new analysis.

Why now? Bridge VIII converts the abstract interleaving infimum into a concrete
weight sup, so the remaining content is purely the combinatorial identity "the
diameter gap is attained on an edge"; the explicit `cloud₁`/`cloud₂` pair already
in `BottleneckStability.lean` is an immediate falsifier if the edge sup ever
strictly exceeds the simplex sup.

### Direction 2 — The isometric embedding into bounded weight functions, and completeness

**Conjecture.** The map `F ↦ F.weight` is an `Isometry` from `(Filtration α,
eInterleavingDist)` onto the set of monotone, `∅`-grounded functions inside
`(Finset α → ℝ)` equipped with the extended sup-emetric
`edist f g = ⨆ σ, ENNReal.ofReal |f σ − g σ|`; moreover this image is *closed*, so
`(Filtration α, eInterleavingDist)` is a **complete** extended metric space and its
Cauchy limits have weight the uniform limit of the weights.

The key insight is that Bridge VIII's formula *is* the statement that `weight` is
distance-preserving; what remains is purely topological, namely that a uniform
(sup-emetric) limit of monotone, `∅`-grounded functions is again monotone and
`∅`-grounded — both are closed conditions defined by non-strict inequalities, hence
preserved under pointwise/uniform limits.

Why now? Completeness was ill-posed while the space had indistinguishable points;
Bridge VII separated them and Bridge VIII identified the metric with a sup-norm on
functions, so completeness reduces to closedness of the constraint set `{w | w ∅ ≤ 0
∧ Monotone w}` — a Mathlib-shaped lemma rather than a persistence question.

### Direction 3 — Functoriality: weight-nondecreasing pullback is 1-Lipschitz

**Conjecture.** A vertex map `f : α → β` induces a pullback
`f* : Filtration β → Filtration α` by `(f* F).weight σ = F.weight (σ.image f)`
(monotone because `image` is), and `f*` is **1-Lipschitz** for `eInterleavingDist`:
`eInterleavingDist (f* F) (f* G) ≤ eInterleavingDist F G`, with *equality* when `f`
is injective. Thus `Filtration` is a functor into extended metric spaces and short
maps.

The key insight is that Bridge VIII turns Lipschitz-ness into a pure sup
comparison: `⨆ σ, |F.weight (σ.image f) − G.weight (σ.image f)|` ranges over a
*subset* of the values `⨆ τ, |F.weight τ − G.weight τ|` (those `τ` in the image of
`·.image f`), so the bound is monotonicity of `⨆` over a reindexing, and injectivity
makes the reindexing surjective onto all `τ`, giving equality.

Why now? Functoriality was unstatable cleanly while the structure was a
pseudometric with an opaque kernel; with the closed-form `eInterleavingDist`,
"short map" is the literal Mathlib predicate `LipschitzWith 1` and the proof is a
`iSup`-mono one-liner over the new formula.

### Direction 4 — Where the isometry breaks: non-Archimedean weight codomains

**Conjecture.** Replace the codomain `ℝ` of `Filtration.weight` by an ordered
additive structure `W` that is not Archimedean / not densely ordered (e.g. the
min-plus tropical semiring of `Catalog/Tropical/MinPlusAlgebra.lean`, or a
discrete value group). Then `interleaved_iff_weightCloseBy` *survives* (it is order
algebra), but the attained-infimum step `eInterleavingDist_le_weightSupEDist`
**fails**: the sup of weight gaps need not be an admissible shift, so
`eInterleavingDist` strictly undercuts `weightSupEDist`, the T0 collapse degenerates
back to a pseudometric, and the Bridge VI `SeparationQuotient` becomes nontrivial.

The key insight is that Bridge VIII isolates the *unique* analytic input — the step
"`c.toReal` is itself a witness", which silently uses `ENNReal.ofReal_toReal` and
the order-completeness of `ℝ` — so removing density/Archimedeanity surgically
removes exactly the attainment, while leaving the relational characterisation
intact; the kernel then measures the order-completeness of `W`, not of the topology.

Why now? Bridge VIII names the load-bearing lemma in one place, making the
counterexample a single explicit `W`-filtration pair; the catalog already ships the
tropical scaffolding to instantiate `W`, so the obstruction is constructible and
falsifiable today.

### Direction 5 — Surjectivity: a representation theorem for the filtration emetric

**Conjecture.** The weight embedding of Direction 2 is **surjective** onto
`{w : Finset α → ℝ | w ∅ ≤ 0 ∧ Monotone w}`: every monotone, `∅`-grounded weight
function arises as `F.weight` for a unique `F`, so `(Filtration α, eInterleavingDist)`
is *isometrically isomorphic* to that constraint set under the sup-emetric. Hence the
interleaving geometry of persistence is, up to isometry, nothing more than the
order interval of monotone functions in sup-norm.

The key insight is that the `Filtration` structure carries exactly the two
propositional fields `weight_empty` and `weight_mono`, so building `F` from a `w`
satisfying the two constraints is immediate (the converse direction of `ext_weight`
from Bridge VII), and Bridge VIII makes the resulting bijection distance-preserving
on the nose.

Why now? `ext_weight` (Bridge VII) gave injectivity and Bridge VIII gave the
isometry; the only missing half is the trivial constructor for surjectivity, after
which the persistence emetric is *completely classified* — turning the entire arc
(IV–VIII) into a representation theorem that downstream homology-stability results
can cite as a black box.
