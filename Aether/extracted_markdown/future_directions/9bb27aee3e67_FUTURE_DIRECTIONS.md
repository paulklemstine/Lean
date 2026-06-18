# Future Directions — Tropical/Arithmetic Height Filtrations as 1-Lipschitz Functors

## Synthesis

This cycle built the missing **Bridges ↔ Applications** interface anticipated by the
catalog: it connects the *tropical valuation* world
(`Bridges/CategoricalTropicalUltrametric.TropicalValuationObject`, whose defining axiom is
`add_eq_max'`) and the *p-adic valuation-depth* world
(`Computation/PadicValuationDepth.ValuationDepthMeasure`) to the *scale-indexed filtered*
world (`Applications/PoincareData/MetricFiltration.ripsGraph` / `ripsGraph_mono`).

The new file `Catalog/Bridges/TropicalHeightFiltration.lean` formalizes the passage
*height function ↦ sublevel tower* and proves it is a **1-Lipschitz functor**. Concretely:

* `sublevel_mono` — sublevel towers are monotone (height analogue of `ripsGraph_mono`);
* `sublevel_shift_subset` — a one-sided additive height bound becomes a shifted inclusion;
* `sublevel_interleaved` — an `L∞` height bound becomes an `ε`-interleaving (the stability
  theorem; this is the falsifiable core);
* `Interleaved.trans` — interleaving parameters add, so the least interleaving is a
  pseudometric on towers (a *purely additive* triangle inequality, needing no monotonicity);
* `sublevel_map_subset` — valuation-nonincreasing maps induce maps of towers (functoriality);
* `sublevel_closed_under_ultrametric` — the tropical axiom `add = max` makes every level a
  sub-structure (ultrametric ⇒ "ideal/subgroup at level t");
* `edgeFiltration` / `edgeFiltration_mono` / `edgeFiltration_interleaved` — the whole story
  lifts levelwise from sets to **graph towers**, with the catalog's `ripsGraph` recovered as
  the `dist`-specialization (`ripsGraph_mono_via_edge`);
* `valuation_perturbation_structured` — capstone: perturbed tropical data simultaneously
  yields interleaving stability *and* preserved level-wise algebraic structure.

A unifying design choice powers all of this: a single `Interleaved` relation over any
`LE`-valued indexed family. With `β = Set X` it is set interleaving (`⊆`); with
`β = SimpleGraph X` it is graph interleaving (`≤`). The set-to-graph lift is then literally
the same theorem at two instances.

## Results Summary

Nine fully proven statements, `sorry = 0`, building only on Mathlib and reusing the
catalog's `ripsGraph` construction conceptually (recovered here as a special case). The
sharp hypothesis isolated by the work: the additive shift/interleaving results need an
*ordered additive monoid* (`IsOrderedAddMonoid`); over a bare `Preorder` only monotonicity
survives. The tropical closure result needs only a `LinearOrder` (to read `max`).

## Direction 1 — A genuine interleaving (pseudo)metric and an algebraic stability theorem

Define `interleavingDist F G := sInf {ε | Interleaved F G ε}` for towers indexed by `ℝ≥0∞`
and prove it is an extended pseudometric: symmetry from `Interleaved.symm`, the triangle
inequality from `Interleaved.trans`, and `interleavingDist (sublevel h₁) (sublevel h₂) ≤
‖h₁ - h₂‖∞`. Then prove the converse bound for *separating* height families, making the
inequality an equality (an isometry theorem: the height-to-tower functor is distance
preserving on a natural class).
**The key insight is** that `Interleaved.trans` is already a metric triangle inequality in
disguise, so the only missing ingredient is taking an infimum over `ε` in a complete ordered
target — no new geometry is required, only `sInf` bookkeeping.
**Why now?** The triangle inequality and the `L∞` upper bound are already proven this cycle;
turning them into a metric statement is the natural and immediately reachable next step, and
it upgrades the qualitative "1-Lipschitz" slogan into a quantitative isometry theorem.

## Direction 2 — p-adic valuation depth instantiates the tropical closure principle

Instantiate `sublevel_closed_under_ultrametric` with the concrete height
`h x = -(padicValRat p x)` (or the p-adic absolute value) and the operation `m = (· + ·)`,
using the strong triangle inequality `v_p(a+b) ≥ min(v_p a, v_p b)`. Prove that each sublevel
set is exactly a fractional-ideal-like additive subgroup, and that the resulting tower is the
filtration by p-adic norm. Tie this back to `Computation/PadicValuationDepth` by showing the
valuation-depth measure `vdepth` is monotone along the tower.
**The key insight is** that the abstract bound `h(m x y) ≤ max (h x) (h y)` proven this cycle
is *precisely* the non-archimedean triangle inequality, so the p-adic case is a direct
instantiation rather than new theory.
**Why now?** Both endpoints already exist in the catalog (`PadicValuationDepth` and the new
tropical closure lemma); connecting them realizes the "arithmetic data → stable filtered
object" pipeline promised by the concept, and Mathlib already has `padicValRat` with the
strong triangle inequality.

## Direction 3 — Persistent-homology stability for arbitrary edge-heights (Rips/Čech)

Upgrade `edgeFiltration_interleaved` from the graph (π₀) level to the persistence-module
level: define the connected-components functor `π₀ ∘ edgeFiltration` and prove a *bottleneck*
stability theorem — the bottleneck distance between the resulting persistence diagrams is at
most `‖w₁ - w₂‖∞`. Specializing `w = dist` reproduces the classical Rips stability theorem,
but the statement now holds for *any* symmetric edge weight (correlation, kernel, learned
metric), connecting to `Applications/BoltzmannBridge/BottleneckStability`.
**The key insight is** that interleaving of filtered objects descends through any functor to
interleaving of persistence modules, and the algebraic interleaving is already established
here; only the algebraic-stability ("interleaving ⇒ bottleneck") half remains.
**Why now?** The graph-level interleaving is proven and the catalog already contains
bottleneck-stability scaffolding; bridging them yields TDA stability for non-metric data, a
genuinely new and falsifiable generalization.

## Direction 4 — Functorial reconstruction: towers determine heights up to interleaving

Prove a reconstruction/rigidity theorem: the functor `h ↦ sublevel h` is faithful in the
sense that `sublevel h₁ = sublevel h₂` (as families) iff `h₁ = h₂`, and more strongly that
`Interleaved (sublevel h₁) (sublevel h₂) ε` forces `‖h₁ - h₂‖∞ ≤ ε` whenever the index set
is dense. Combined with `sublevel_map_subset`, this would exhibit an equivalence of
categories between "height spaces with valuation-nonincreasing maps" and "interleaving
towers with tower morphisms".
**The key insight is** that a height is recoverable from its tower via `h x = sInf {t | x ∈
sublevel h t}`, the order-theoretic adjoint of the sublevel construction, so faithfulness is
a Galois-connection statement rather than a hard analysis problem.
**Why now?** The forward functor and its 1-Lipschitz bounds are complete this cycle; the
adjoint (inf-of-sublevels) is elementary in Mathlib's complete lattices, making the
categorical equivalence the natural capstone that closes the bridge into a true equivalence.
