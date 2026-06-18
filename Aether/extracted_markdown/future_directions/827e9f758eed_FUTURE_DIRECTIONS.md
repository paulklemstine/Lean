# Future Directions — Boltzmann Bridge X: The Lattice of Filtrations and Order-Functoriality

## Synthesis

`Catalog/Applications/BoltzmannBridge/InterleavingLattice.lean` (Bridge X) fuses the
three structural layers that the persistence arc had developed separately:

* the **representation theorem** of Bridge IX (`weightEquiv`, `ofWeight`,
  `weight_surjective`), which identifies `Filtration α` with the monotone,
  `∅`-grounded functions `Finset α → ℝ`;
* the **isometry formula** of Bridge VIII (`eInterleavingDist_eq_weightSupEDist`),
  which pins the interleaving emetric to the sup-distance of weights;
* the **contravariant pullback functor** of Bridge IX (`pullback`, `pullback_id`,
  `pullback_comp`, `eInterleavingDist_pullback_eq_of_surjective`).

Bridge IX showed the carrier *is* a set of functions cut out by two `≤`-constraints,
both preserved by pointwise `max`/`min`. Bridge X turns that observation into
algebra:

* **The pointwise order** `F ≤ G ↔ ∀ σ, F.weight σ ≤ G.weight σ` makes
  `Filtration α` a `PartialOrder` — antisymmetry is exactly Bridge VII's `ext_weight`
  ("a filtration is its weight").
* **`Filtration α` is a `Lattice`** (`instLatticeFiltration`), with
  `(F ⊔ G).weight = F.weight ⊔ G.weight` and `(F ⊓ G).weight = F.weight ⊓ G.weight`
  holding *definitionally* (`weight_sup`, `weight_inf`).
* **The pullback functor is a lattice homomorphism**: monotone (`pullback_mono`) and
  commuting with `⊔`/`⊓` (`pullback_sup`, `pullback_inf`), because precomposition with
  `·.image f` acts pointwise.
* **`weightEquiv` is an order isomorphism** (`weightOrderIso`): the representation of
  Bridge IX is an iso of partial orders, not merely a bijection — its `map_rel_iff'`
  is `Iff.rfl` on the underlying pointwise relation.
* **The metric–order bridge** `eInterleavingDist_of_le`: for comparable filtrations
  the absolute value in Bridge VIII's formula disappears,
  `F ≤ G ⟹ eInterleavingDist F G = ⨆ σ, ENNReal.ofReal (G.weight σ − F.weight σ)`,
  and consequently join and meet are nonexpansive (`eInterleavingDist_sup_le`,
  `eInterleavingDist_inf_le`).
* **Faithfulness (Direction 5 of Bridge IX)**: `pullback` along a surjection is
  *injective* (`pullback_injective_of_surjective`) — the companion to Bridge IX's
  isometry-under-surjection, so the persistence functor is faithful on surjections.

The methodological lesson sharpens Bridge IX's: once the carrier is a function set
defined by `≤`-constraints, *order* questions are pointwise bookkeeping
(`le_sup`/`inf_le`, `Iff.rfl`), and the *only* place analysis enters is the metric,
through Bridge VIII — where even there the order hypothesis collapses `|·|` to a
difference.

## Results Summary

All theorems in `InterleavingLattice.lean` compile with `sorry`-count `0` and depend
only on `propext`, `Classical.choice`, `Quot.sound`.

| Theorem | Statement |
|---|---|
| `instPartialOrderFiltration` / `weight_le_iff` | the pointwise order; `F ≤ G ↔ ∀ σ, F.weight σ ≤ G.weight σ` |
| `instLatticeFiltration` / `weight_sup` / `weight_inf` | `Filtration α` is a lattice with pointwise `⊔`/`⊓` |
| `pullback_mono` | the pullback functor is order-preserving |
| `pullback_sup` / `pullback_inf` | the pullback functor is a lattice homomorphism |
| `weightOrderIso` | the representation bijection is an order isomorphism |
| `eInterleavingDist_of_le` | between comparable filtrations the distance is the sup-gap |
| `eInterleavingDist_sup_le` / `eInterleavingDist_inf_le` | join and meet are nonexpansive |
| `pullback_injective_of_surjective` | pullback along a surjection is injective (faithfulness) |

## Falsifiable Research Directions

### Direction 1 — The lattice is conditionally complete, and the metric realizes the order completion

**Conjecture.** Over a finite vertex type `α` (so `Finset α` is finite),
`Filtration α` is not merely a lattice but a *complete* lattice: every family
`{Fᵢ}` has a supremum with `(⨆ᵢ Fᵢ).weight σ = ⨆ᵢ Fᵢ.weight σ` and dually for `⨅`,
because pointwise suprema of monotone, `∅`-grounded functions over a finite domain
are again monotone and `∅`-grounded. Moreover the order and the metric *agree at the
top*: for a monotone increasing chain `F₀ ≤ F₁ ≤ ⋯` the join `⨆ₙ Fₙ` is the
`eInterleavingDist`-limit of the `Fₙ`, i.e. `eInterleavingDist Fₙ (⨆ₘ Fₘ) → 0`.

The key insight is that Bridge X has already shown `weightEquiv` is an order iso onto
the constraint set `{w // w ∅ ≤ 0 ∧ Monotone w}`, and over a finite `Finset α` that
set is closed under arbitrary pointwise `⨆`/`⨅`; combined with
`eInterleavingDist_of_le`, the metric gap to the join is `⨆ σ ((⨆ₘ Fₘ).weight σ −
Fₙ.weight σ)`, a sup over a *finite* index set of tails that vanish — so order
convergence and metric convergence are the same statement.

Why now? Bridge X turned `Filtration α` into an explicit lattice with pointwise
`⊔`/`⊓` and a closed-form distance between comparable elements, so completeness is no
longer a topological question but the finite-domain fact "a pointwise sup of monotone
functions is monotone"; an immediate falsifier would be a finite chain whose pointwise
sup violates `w ∅ ≤ 0`, which cannot happen because `Fₙ.weight ∅ ≤ 0` for all `n`,
making the conjecture sharp.

### Direction 2 — The pushforward is the left adjoint of pullback (a Galois connection)

**Conjecture.** For `f : α → β` with `α` finite there is a **pushforward**
`pushforward f : Filtration α → Filtration β`, defined on weights by
`(pushforward f F).weight τ = ⨆ {F.weight σ | σ.image f ⊆ τ}` (a finite sup, hence a
genuine real, monotone in `τ`, and `∅`-grounded), which forms a Galois connection
with the Bridge IX `pullback`:
`pushforward f F ≤ G ↔ F ≤ pullback f G` in the Bridge X order. Consequently
`pushforward f` is monotone, `pullback f ∘ pushforward f ≥ id`,
`pushforward f ∘ pullback f ≤ id`, and `pushforward f` is `1`-Lipschitz for
`eInterleavingDist`.

The key insight is that Bridge X identified `Filtration α` with the complete lattice
of monotone `∅`-grounded functions under pointwise `≤`, and `pullback f` is precisely
precomposition with `·.image f` on that lattice (`pullback_weight`); precomposition
between complete lattices always has a left adjoint given by the displayed left-Kan
`⨆`-formula, so the Galois connection is a one-line `le_iSup`/`iSup_le` argument
rather than any categorical abstraction — and `pullback_mono` is already the "easy
half" of the adjunction's monotonicity.

Why now? `pullback` is a verified monotone lattice hom (Bridge X) and the carrier is
an explicit function lattice, so the adjoint exists by the poset adjoint functor
theorem with an *executable* witness over finite `α`; the conjecture is falsified the
instant the displayed `⨆` fails `∅`-grounding — exactly when no `σ` satisfies
`σ.image f ⊆ τ`, pinpointing (via `∅.image f = ∅ ⊆ τ`) that the empty simplex always
qualifies, so grounding never fails and the construction is total.

### Direction 3 — Vietoris–Rips stability is an entrywise isometry on the order

**Conjecture.** For symmetric, hollow distance matrices `d₁ d₂ : α → α → ℝ` over a
finite vertex type with `d₁ ≤ d₂` entrywise (`∀ x y, d₁ x y ≤ d₂ x y`), the diameter
filtrations are *comparable in the Bridge X order*,
`diamFiltrationOf d₁ ≤ diamFiltrationOf d₂` (because `diamWeightOf` is a `sup'` and
`sup'` is monotone in the data), and then `eInterleavingDist_of_le` gives the exact
gap `eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) = ⨆ σ,
ENNReal.ofReal (diamWeightOf d₂ σ − diamWeightOf d₁ σ) = ⨆ x, ⨆ y,
ENNReal.ofReal (d₂ x y − d₁ x y)`, sharpening the one-sided `vr_eStability` (Bridge
V) to an equality for ordered matrices.

The key insight is that the order hypothesis `d₁ ≤ d₂` lets Bridge X's
`eInterleavingDist_of_le` strip the absolute value *before* any extremal-pair
analysis, reducing the claim to the purely combinatorial identity "the gap of two
`sup'`s of ordered families is attained on a single edge", which is `Finset.sup'`
monotonicity plus the pair realizing `diamWeightOf d₂ σ`.

Why now? Bridge X supplies both the order comparison of VR filtrations (via
`sup'`-monotonicity feeding `weight_le_iff`) and the closed-form distance for
comparable filtrations, so the only residue is the edge-attainment lemma; the explicit
`cloud₁ ≤ cloud₂` pair in `BottleneckStability.lean` is an immediate falsifier if the
edge sup ever strictly exceeds the simplex sup.

### Direction 4 — Where the order survives but the lattice/metric fusion breaks: non-Archimedean codomains

**Conjecture.** Replace the weight codomain `ℝ` by an ordered additive structure `W`
that is a lattice but *not* order-complete or not densely ordered (e.g. the min-plus
tropical semiring of `Catalog/Tropical/MinPlusAlgebra.lean`, or a discrete value
group). Then the Bridge X *order layer* survives verbatim — `Filtration_W α` is still a
`PartialOrder` and a `Lattice`, `pullback` is still a lattice hom, and `weightEquiv` is
still an order iso, because all of these are pure pointwise order algebra. But the
*metric–order fusion* `eInterleavingDist_of_le` **fails**: the analytic step in Bridge
VIII (the sup of weight gaps is itself an admissible interleaving shift, silently using
`ENNReal.ofReal_toReal` and order-completeness of `ℝ`) no longer holds, so the
interleaving distance strictly undercuts the order gap and the join/meet need not be
nonexpansive.

The key insight is that Bridge X cleanly stratifies the theory into an
order-algebraic layer (codomain-agnostic) and a single analytic layer (the metric
fusion), so swapping `W` surgically removes only the latter — the residual gap between
`eInterleavingDist` and `⨆ σ (G.weight σ − F.weight σ)` then *measures* the
order-incompleteness of `W`.

Why now? Bridge X names exactly one load-bearing analytic input
(`eInterleavingDist_of_le` via Bridge VIII) and shows everything else is order
algebra, so a counterexample is a single explicit `W`-filtration pair; the catalog
already ships the tropical scaffolding to instantiate `W`, making the obstruction
constructible and falsifiable today.

### Direction 5 — The persistence functor is a full faithful lattice-enriched (co)presheaf

**Conjecture.** The assignment `α ↦ Filtration α`, `f ↦ pullback f` is a faithful
contravariant functor from (finite vertex types, surjections) to (lattices, lattice
homomorphisms): on surjections it is faithful (`pullback_injective_of_surjective`,
Bridge X) *and* the metric is preserved (`eInterleavingDist_pullback_eq_of_surjective`,
Bridge IX), so `pullback` lands in *injective lattice-and-metric* homomorphisms;
conversely, `pullback f` is injective **iff** `f` is surjective, giving a clean
dichotomy that characterizes surjectivity through the functor alone.

The key insight is that Bridge X already gives the two implications of the "iff" in
the easy direction (surjective ⟹ injective pullback) and the lattice-hom structure
(`pullback_sup`/`pullback_inf`), so the remaining content is the converse — a
non-surjective `f` leaves some `τ ∈ Finset β` outside the image of `·.image f`, where
two filtrations differing only at `τ` share a pullback — which is a direct
`ext_weight` construction using the representation theorem.

Why now? With `pullback` a verified faithful lattice hom that is an isometry on
surjections (Bridges IX–X), "faithful/full" reduce to literal statements about the
surjectivity of `σ ↦ σ.image f`, and the dichotomy is falsified by any non-surjective
`f` whose pullback is nonetheless injective — which the representation theorem
(distinct weights ⟹ distinct filtrations) shows is impossible, making the conjecture
sharp.
