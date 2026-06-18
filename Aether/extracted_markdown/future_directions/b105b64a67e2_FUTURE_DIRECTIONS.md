# Future Directions — Valuation-Depth Sublevel Filtrations ↔ Metric Rips Filtrations

These conjectures build on `Bridges/ValuationRipsBridge.lean`, which established that in a
non-archimedean (ultrametric) space the closed Rips relation is an equivalence relation at
every scale, that Rips reachability equals the closed-ball relation (`ripsReachable_iff`),
and that the metric Rips filtration coincides with a valuation-depth sublevel filtration via
the functor `DepthFiltration.ofUltrametric` (concretely realized on `ℤ_[p]`).

Each conjecture below is stated to be **falsifiable** and **formalizable** in Lean 4.

---

## Conjecture 1 — Vanishing higher persistent homology (ultrametric Rips collapse)

**Statement.** For a finite ultrametric space `X`, the Vietoris–Rips complex at every scale
`ε ≥ 0` is homotopy equivalent to a disjoint union of points (its `π₀`); equivalently, all
reduced homology groups `H̃_n(Rips(X, ε))` vanish for `n ≥ 1`, at every scale.

**Why plausible.** `ripsReachable_iff` shows each Rips component is a *clique* (the whole
closed ε-ball), and the clique/Vietoris–Rips complex of a complete graph is a simplex, hence
contractible. The bridge file already proves the `π₀`/1-skeleton statement; this conjecture
is its higher-dimensional completion.

**Test / falsification.** Formalize "each component induces a complete graph" (immediate from
`ripsRel_trans`) and connect to a simplicial-complex contractibility lemma. A single
ultrametric point cloud with nontrivial `H_1` would falsify it.

---

## Conjecture 2 — Persistence diagrams of ultrametric spaces are dendrograms

**Statement.** The persistence module of `π₀` of the Rips filtration of a finite ultrametric
space is a **functor from `(ℝ, ≤)` to finite partitions** that is *monotone coarsening*, and
its barcode is in bijection with the merge events of single-linkage hierarchical clustering
(a rooted dendrogram). No `H_0` bar is ever "born after" another bar without a corresponding
ball-merge.

**Why plausible.** `ripsRel_mono` + `ripsSetoid` give a chain of coarsening equivalence
relations; the births/deaths of components are exactly the distinct values of the ultrametric.

**Test / falsification.** Define `numComponents X ε := Nat` (number of `ripsSetoid` classes)
and prove it is a monotone step function of `ε` whose jump set equals the image of `dist`.
Falsified by an ultrametric space whose component-count function has a jump at a non-distance
value.

---

## Conjecture 3 — Functoriality is full: every depth filtration is ultrametric

**Statement.** The functor `DepthFiltration.ofUltrametric` is *essentially surjective*: every
abstract `DepthFiltration X` (a nested family of equivalence relations) arises, up to
relabeling of depths, from a genuine ultrametric pseudometric on `X` via the schedule
`s n = 2^{-n}`. Concretely, `d(x,y) := 2^{-(sup {k | agree k x y})}` (with `d = 0` when the
set is unbounded) is an `IsUltrametricDist` pseudometric whose induced depth filtration
recovers the original `agree`.

**Why plausible.** The `agree_trans` axiom is exactly the ultrametric strong-triangle
inequality transported through `2^{-(·)}`; `agree_antitone` gives monotonicity of the sup.

**Test / falsification.** Construct `DepthFiltration.toUltrametric : DepthFiltration X →
PseudoMetricSpace X` with an `IsUltrametricDist` instance and prove a round-trip lemma
`(ofUltrametric ∘ toUltrametric).agree = agree`. Falsified if some `agree` cannot satisfy the
ultrametric inequality after `2^{-(·)}` transport (it always can, so this should be provable).

---

## Conjecture 4 — `p`-adic Rips threshold equals the valuation gap

**Statement.** For a finite set `S ⊆ ℤ_[p]`, the **connectivity threshold** of the Rips
filtration — the smallest `ε` at which `ripsGraph ℤ_[p] ε` restricted to `S` is connected —
equals `p^{-m}`, where `m` is the minimal `p`-adic valuation depth that already merges all of
`S` into one congruence class modulo `pᵐ`. Equivalently, the connectivity threshold is the
largest "valuation gap" `max_{i} (v_i - v_{i-1})` along the sorted pairwise valuations.

**Why plausible.** `padic_dist_le_pow_iff` identifies Rips edges at scale `p^{-n}` with
congruence mod `pⁿ`; connectivity is the coarsest partition becoming trivial, i.e. the
deepest valuation level at which all points still merge.

**Test / falsification.** Compute both sides for explicit finite subsets of `ℤ_[2]` and prove
equality. A subset where the connectivity threshold disagrees with the maximal valuation gap
would falsify it.

---

## Conjecture 5 — Archimedean defect quantifies non-transitivity

**Statement.** Define the *Rips transitivity defect* of a metric space at scale `ε` as the
supremum over triples `(x,y,z)` of `dist x z - max (dist x y) (dist y z)` (clamped at `0`).
Then this defect is identically `0` **iff** the space is ultrametric, and for a general
metric space it gives a tight, scale-independent upper bound on how much larger the Rips
*reachability* relation can be than the closed Rips relation:
`(reachable at ε) ⊆ (closed ball at ε + (n−1)·defect)` along paths of length `n`.

**Why plausible.** `rips_rel_not_trans_real` exhibits a strictly positive defect on `ℝ`
producing exactly the gap in `rips_reachable_ne_rel_real`; the ultrametric case has defect `0`
and `ripsReachable_iff` collapses reachability to the closed ball.

**Test / falsification.** Formalize the defect, prove `defect = 0 ↔ IsUltrametricDist`, and a
path-length bound. Falsified by a metric space with zero defect that is not ultrametric, or by
a reachable pair exceeding the stated bound.
