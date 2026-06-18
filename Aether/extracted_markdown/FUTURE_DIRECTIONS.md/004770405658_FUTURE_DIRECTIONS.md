# Future Directions — Tropical Persistence Profile from Rips Component Counts

Derived from the research cycle formalized in
`Catalog/Bridges/TropicalComponentProfile.lean` and
`Catalog/Bridges/TropicalComponentFunctorial.lean`.

These files established, for a finite pseudometric space `α`:

* the component-count profile `componentCount α t = Nat.card (ripsGraph α t).ConnectedComponent`;
* merge monotonicity `componentCount_antitone`, the boundary value
  `componentCount_eq_card_of_neg`, and the upper bound `componentCount_le_card`;
* isometry invariance `componentCount_isometry`;
* the lattice→tropical linearization `componentCount_min_eq_max`;
* a concrete `(max, +)` tropical valuation object `maxPlusTrop` on `WithBot ℕ`, with the bridge
  identity `componentCount_tropical_add`: `add (c t₁) (c t₂) = c (min t₁ t₂)`;
* functoriality of the connected-component sets in both the space (`componentMap_comp`) and the
  scale (`componentMap_naturality`).

The cycle's Analysis stage isolated two robust phenomena: (a) antitone profiles convert the
`min`-lattice of scales into the `max`-lattice of counts (a tropical addition), and (b) the
component sets — not just their cardinalities — form a bifunctor. The following conjectures push
on exactly those two findings.

---

## C1. The merge profile is a tropical valuation morphism, not just a monotone map.

**Conjecture.** The dual merge profile `m(t) = #α − c(t)` extends to a `TropHom` from `maxPlusTrop`
(reindexed by scale) into the `min`-plus tropical object, intertwining the scale lattice with the
count lattice; i.e. `min (m t₁) (m t₂) = m (min t₁ t₂)` and the assignment is a structure-preserving
map of `TropObj`s in the sense of `Bridges/CategoricalTropicalUltrametric.lean`.

**The key insight is** that `c` already turns `min` of scales into `max` of counts
(`componentCount_min_eq_max`), so its `#α`-complement must turn `min` of scales into `min` of merge
counts — a *second*, dual tropical law that upgrades the numeric profile to an actual `TropHom`.

**Why now?** `maxPlusTrop` and the `TropHom` category are both already in the catalog, and the
numeric identity is proved, so only the morphism-packaging remains — a short, well-scoped step.

---

## C2. Stability: the component profile is `1`-Lipschitz in Gromov–Hausdorff-type perturbations.

**Conjecture.** If two finite spaces are related by an `ε`-isometry (a not-necessarily-bijective
map distorting distances by at most `ε`), then their component profiles satisfy an interleaving
`c_α(t+ε) ≤ c_β(t) ≤ c_α(t−ε)` (up to the usual persistence shift), making `componentCount` a
stable persistence invariant.

**The key insight is** that `componentMap` already exists for exact `1`-Lipschitz maps
(`ripsHom`); relaxing exactness to an additive `ε` should shift the scale argument by `ε` rather
than break the homomorphism, yielding an interleaving instead of an equality.

**Why now?** Exact isometry invariance (`componentCount_isometry`) and the functorial machinery
(`componentMap_naturality`) are in place; the perturbed version is the natural quantitative
generalization and connects directly to persistence-stability libraries already in
`Applications/BoltzmannBridge/PersistenceStability.lean`.

---

## C3. Disjoint unions realize tropical *multiplication* of profiles.

**Conjecture.** For the metric disjoint union `α ⊔ β` (cross-distances set above every intra-cluster
scale of interest), the profile multiplies tropically: in `maxPlusTrop`,
`c_{α⊔β}(t) = mul (c_α(t)) (c_β(t))` for `t` below the cross-distance, i.e. component counts *add*
as integers and hence *multiply* in the `(max,+)` semiring.

**The key insight is** that `Nat.card` of a disjoint union of graphs is the sum of the two
component counts, and addition of integers *is* tropical multiplication — so `maxPlusTrop`'s
multiplicative structure (currently only axiomatized) acquires a concrete geometric meaning.

**Why now?** `maxPlusTrop.mul` is defined and proven to satisfy the semiring axioms; supplying the
disjoint-union metric and the additivity lemma turns an abstract operation into a theorem with
geometric content, completing the semiring picture begun in this cycle.

---

## C4. The profile detects the connectivity (Poincaré) threshold exactly.

**Conjecture.** For a finite space, `c(t) = 1` for all `t ≥ τ` and `c(t) > 1` for `t < τ`, where
`τ` is the connectivity threshold (the largest edge in a minimum spanning tree). Moreover `τ` is
the unique scale at which `mergeCount` first reaches `#α − 1`.

**The key insight is** that the merge profile increases by exactly the number of MST edges crossed,
so the single-cluster boundary of `componentCount` coincides with the top MST edge — linking the
tropical profile to `Applications/ProteinFoldingMST.lean`.

**Why now?** `mergeCount_monotone` and `componentCount_le_card` already bound the profile between
`1` and `#α`; identifying the exact transition scale via MST edges is the natural next theorem and
bridges two existing catalog programs (metric filtrations and MST).

---

## C5. The bifunctor refines to an order isomorphism of profile lattices under isometry.

**Conjecture.** The assignment `α ↦ (t ↦ (ripsGraph α t).ConnectedComponent)` is a full functor on
the groupoid of finite isometries: every isometry induces, naturally in `t`, a bijection of
component sets, and these bijections are the *only* natural isomorphisms of profiles (rigidity).

**The key insight is** that `componentMap_naturality` plus `componentCount_isometry` already give a
natural family of bijections; rigidity would show the persistence profile is a *complete* isometry
invariant on a suitable subclass (e.g. spaces in general position).

**Why now?** The naturality square and isometry bijection are both formalized in this cycle, so the
remaining content is a faithfulness/fullness statement — a clean categorical capstone that would
elevate the profile from an invariant to a classifying object.
