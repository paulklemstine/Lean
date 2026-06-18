# Future Directions — Component-Count Tropical Valuation Functor from Rips Filtrations

Companion to `Catalog/Bridges/RipsComponentTropical.lean`, which establishes:

- `componentCount_antitone` — the π₀ component count is a contravariant functor `(ℝ,≤) ⥤ (ℕ,≥)`;
- `connAt_max` — connectivity-at-scale is closed under the tropical sum `max` (`⊕`);
- `mergeScale_ultratriangle` — the single-linkage merge scale is an ultrametric (tropical valuation);
- `mergeScale_le_dist` — the merge ultrametric is a contraction of the ambient metric;
- `ripsPi0Functor` — the bundled tropical π₀ functor with filtration boundary;
- `connAt_mergeScale` / `connAt_iff_mergeScale_le` — on finite spaces the merge infimum is
  attained, closing the loop `ConnAt α ε x y ↔ mergeScale x y ≤ ε` for `ε ≥ 0`.

The following conjectures are precise and testable in Lean 4 + Mathlib.

## Conjecture 1 (π₀ ↔ ultrametric reconstruction — "closing the loop")
PARTIALLY RESOLVED in this cycle: the relation-level equivalence `connAt α ε x y ↔ mergeScale x y ≤ ε`
(for `ε ≥ 0`, finite `α`) is now proved (`connAt_iff_mergeScale_le`). REMAINING OPEN PART: the
*counting* form. Define the threshold graph `ultraThresholdGraph ε` on `α` by adjacency
`x ≠ y ∧ mergeScale x y ≤ ε`. Conjecture: it equals `ripsGraph α ε` (as `SimpleGraph α`) for `ε ≥ 0`,
hence `componentCount α ε = Nat.card (ultraThresholdGraph ε).ConnectedComponent`. Note adjacency
is strictly weaker than `ripsGraph` adjacency in general (mergeScale ≤ dist), so the two graphs
need NOT be edge-equal — the conjecture is that they have the SAME connected components and hence
the same component count. This would make `mergeScale` a *complete* π₀ invariant, realizing the
"valuation reconstruction is a functor" thesis.

## Conjecture 2 (Merge-count conservation / persistence)
For finite nonempty `α`, the total number of merge events is conserved:
`Nat.card α - componentCount α ε` counts exactly the merges completed by scale `ε`, and
`∑` of "merge multiplicities" over the finite set of critical scales equals `Nat.card α - 1`
when the space becomes connected (`componentCount α ε = 1` for `ε ≥ diam`). Testable as a
telescoping identity over the finite image of `componentCount`.

## Conjecture 3 (Stability / 1-Lipschitz transfer of the merge valuation)
The merge ultrametric is 1-Lipschitz in the input metric: if `d, d'` are two pseudometrics
on `α` with `|d x y − d' x y| ≤ δ` for all `x, y`, then `|mergeScale_d x y − mergeScale_d' x y| ≤ δ`.
This is the tropical analogue of the persistence stability theorem and should follow from
`connAt_max` plus a `δ`-comparison of Rips graphs.

## Conjecture 4 (Functoriality under 1-Lipschitz maps)
A 1-Lipschitz map `f : α → β` induces, for every scale, a graph homomorphism
`ripsGraph α ε →g ripsGraph β ε` on non-collapsed pairs, hence a natural surjection-free map of
components giving `componentCount β ε ≤ componentCount α ε` when `f` is surjective, and
`mergeScale (f x) (f y) ≤ mergeScale x y`. This upgrades `componentCount` and `mergeScale`
to genuine functors on the category of finite pseudometric spaces and 1-Lipschitz maps.

## Conjecture 5 (Tropical semiring valuation structure)
The pair `(componentCount, mergeScale)` assembles into a valuation into the tropical semiring
`(ℝ ∪ {∞}, max, +)`: define `ν(x,y) = mergeScale x y` and verify the tropical valuation axioms
`ν(x,z) ≤ ν(x,y) ⊕ ν(y,z)` (proved: `mergeScale_ultratriangle`) together with a multiplicative
compatibility `ν(x,y) ⊙ c ≥ ν(scaled)` under metric scaling `d ↦ c·d`, namely
`mergeScale_{c·d} x y = c · mergeScale_d x y` for `c ≥ 0`. This would instantiate
`CategoricalTropicalUltrametric.TropicalValuationObject` directly from a Rips filtration.
