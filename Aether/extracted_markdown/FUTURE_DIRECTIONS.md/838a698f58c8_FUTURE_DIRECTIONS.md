# Future Directions: Tropical Compactification of Moduli Spaces

This cycle created `Catalog/Tropical/TropicalModuliCompactification.lean`, an
abstract formalization of the ultrametric / phylogenetic core of the tropical
moduli space `M_{0,n}^trop` (equivalently, a cone in the tropical Grassmannian
`Gr(2,n)`).

## Synthesis

We replaced the catalog's *concrete* p-adic ultrametric facts
(`Catalog/MachineLearning/UltrametricFoundations.lean`, where `ultrametric_isosceles`
lives over `ℚ_p`) with an **abstract** dissimilarity `d : ι → ι → ℝ` carrying only
symmetry, nonnegativity, and the strong (non-Archimedean) triangle inequality —
the exact setting of phylogenetics and of the equidistant locus of `M_{0,n}^trop`.
From this minimal data we proved the full isosceles/"max-attained-twice" tower:
the three-point and four-point tropical Plücker relations, the embedding of the
ultrametric locus into the ordinary metric cone, and max-plus homogeneity (the
cone/fan scaling action).

The structural insight that emerged is that a *single* asymmetric atom —
"if two sides differ, the larger two are equal" (`IsUltrametric.isosceles`) —
generates everything: the three-point Plücker relation is one trichotomy split on
top of it, and the four-point Plücker relation reduces to collecting the
per-triple `max`-rewrite identities `max (d a b) (d b c) = max (d a c) (d b c)`
over the triples spanning a quadruple and letting `grind` assemble them. What
*failed* was the naive route of deriving the four-point relation by hand-algebra
from the three-point relation: it was brittle and order-of-`max` sensitive.
Re-expressing each triple as a `max`-identity (rather than a disjunction) was the
unlock — disjunctions do not chain, equalities do.

This positions the next cycle to attack the converse (reconstruction) direction:
we now have the defining inequalities of the `Gr(2,n)` cone as reusable Lean
lemmas, so the fan structure and the Buneman tree-recovery can be assembled *from*
them rather than re-derived. The homogeneity lemma already certifies closure under
tropical scaling; the missing cone operation is closure under coordinatewise `max`.

## Results Summary

- `IsUltrametric.isosceles`: proved — every ultrametric triangle is isosceles
  (strict inequality of two sides forces the larger two to be equal); the atomic
  fact underlying all other results.
- `IsUltrametric.attainedTwice_triple`: proved — the three-point tropical Plücker
  relation; among three pairwise distances the maximum is attained at least twice.
- `IsUltrametric.triangle`: proved — an ultrametric is a genuine pseudometric,
  embedding the ultrametric locus into the looser tree-metric cone.
- `IsUltrametric.smul`: proved — max-plus homogeneity; the locus is closed under
  tropical scaling by a nonnegative constant (the cone/fan scaling action).
- `IsUltrametric.attainedTwice_four_point`: proved — the four-point tropical
  Plücker relation on a quadruple, the defining inequality of the `Gr(2,n)` cone.

## Research Directions

### Direction 1: Closure under coordinatewise `max` (tropical submodule)
**Hypothesis**: If `d₁` and `d₂` satisfy `IsUltrametric`, then so does
`fun x y => max (d₁ x y) (d₂ x y)`; together with `IsUltrametric.smul` this makes
the ultrametric locus a max-plus submodule of `ι → ι → ℝ`.
**Test**: State the lemma `IsUltrametric.sup` and attempt it; the only nontrivial
field is `strong`, which reduces to `max (d₁ x z) (d₂ x z) ≤ max (max (d₁ x y) (d₂ x y)) (max (d₁ y z) (d₂ y z))`,
a pure `max`-lattice inequality dischargeable by `grind`/`lattice` after applying
each `strong`.
**Why now**: `IsUltrametric.smul` already gives the scalar half of the cone
structure, so submodule-hood is exactly one missing closure lemma of the same shape.
**If true**: the ultrametric locus is a genuine tropical (max-plus) submodule,
the first algebraic step toward the balanced-fan statement of Speyer–Sturmfels.
**If false**: the counterexample would localize precisely which two-tree overlay
breaks the strong triangle inequality, sharpening the definition of the fan.

### Direction 2: Closedness under pointwise limits (compact boundary)
**Hypothesis**: If `dₖ → d` pointwise and each `dₖ` satisfies `IsUltrametric`,
then `d` satisfies `IsUltrametric`; hence the locus is closed.
**Test**: Transport each field through `Filter.Tendsto` using `le_of_tendsto`
and continuity of `max`; `nonneg`/`symm` pass to the limit trivially, `strong`
via `isClosed_le` applied to the continuous maps `d x z` and `max (d x y) (d y z)`.
**Why now**: every field of `IsUltrametric` is a non-strict `≤`/`max` condition,
i.e. closed, and Mathlib's order-limit API is mature.
**If true**: `M_{0,n}^trop` acquires a genuine closed-boundary compactification
structure inside the space of symmetric nonnegative functions.
**If false**: it would mean a defining condition is secretly open, exposing a hidden
strictness in the moduli definition.

### Direction 3: Quantitative isosceles defect (almost-ultrametrics)
**Hypothesis**: Define `δ x y z` as the gap between the two largest of
`d x y, d y z, d x z`. Then `d` is within sup-norm `ε` of some ultrametric iff
`δ ≤ C·ε` uniformly, with a universal `C` independent of `|ι|`.
**Test**: The `ε = 0` boundary is exactly `attainedTwice_triple` (`δ = 0`). Perturb
`strong` to `d x z ≤ max (d x y) (d y z) + ε` and re-run the trichotomy to get a
two-sided estimate; prove the forward bound first as a standalone lemma.
**Why now**: we have the exact `ε = 0` equality in hand, so the perturbed squeeze
is a direct generalization rather than a new argument.
**If true**: bridges the pure moduli side with the catalog's tropical robustness
files via a clean Lipschitz defect bound.
**If false**: a divergent `C` as `|ι|` grows would reveal an inherent dimension
dependence in ultrametric approximation.

### Direction 4: Buneman reconstruction (four-point ⇒ tree)
**Hypothesis**: A symmetric nonnegative `d` on a finite type satisfies the
four-point condition for *every* quadruple iff there is a weighted tree (finite
graph metric) realizing `d` exactly.
**Test**: The forward direction is `attainedTwice_four_point` generalized off the
equidistant locus; the converse is a finite induction on `|ι|`, splitting off one
leaf at a time using the equality case of the four-point disjunction as the split
certificate.
**Why now**: the four-point relation is now a machine-checked disjunction, exactly
the gluing datum a split-by-split reconstruction consumes.
**If true**: completes the constructive heart of `M_{0,n}^trop` (the tree ↔ metric
equivalence).
**If false**: a four-point-satisfying non-tree metric would be a genuinely new
combinatorial object worth isolating.

### Direction 5: Ultrametric ↔ dendrogram bijection (clustering certificates)
**Hypothesis**: Every ultrametric on a finite set arises, up to monotone
reparametrization, from a single-linkage hierarchical clustering dendrogram, and
conversely; the bijection equips the catalog's `PAdicTropical` valuations with a
verified ultrametric semantics.
**Test**: Formalize the merge rule "two points enter the same cluster at the same
height" and show it is `attainedTwice_triple` in disguise; build the dendrogram by
finite recursion with loop invariant `attainedTwice_triple`.
**Why now**: `attainedTwice_triple` already gives the canonical merge witness, so
the recursion's invariant is in hand.
**If true**: a cross-domain bridge linking moduli/phylogenetics to the catalog's
p-adic and clustering material.
**If false**: a non-dendrogram ultrametric would refute the folklore equivalence and
demand a weaker reparametrization class.
