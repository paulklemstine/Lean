# Future Directions — Arithmetic–Tropical Filtration Stability

## Synthesis

This cycle built a concrete **Bridges → Applications** pipeline connecting three
previously isolated catalog components:

* `Bridges/ArithmeticVCDimension.lean` — the arithmetic height measure
  `ratArithHeight` / `ArithHeightMeasure` on rational data;
* `Bridges/CategoricalTropicalUltrametric.lean` — the
  `TropicalValuationObject` interface encoding the tropical "addition = max"
  principle and its ultranorm reconstruction;
* `Applications/PoincareData/MetricFiltration.lean` — the Rips-graph filtration
  API (`ripsGraph`, `ripsGraph_mono`).

The new file `Bridges/ArithmeticTropicalFiltration.lean` composes them into a
single *stability theory*. We generalized the Rips graph to an arbitrary pairwise
distance (`ripsGraphF`), recovered the catalog `ripsGraph` as the `dist`
instance (`ripsGraphF_eq_ripsGraph`), and proved the two abstract comparison
theorems (`ripsGraphF_mono_of_dist_le`, `ripsGraphF_shift_of_dist_le_add`). We
then extracted the purely tropical ultrametric inequality from the bare
`TropicalValuationObject` axioms (`tropMax_ultra`), instantiated it as a concrete
ℝ-valued height ultranorm (`heightUltra`, with `heightUltra_ultra` the strong
triangle inequality and `heightUltra_le_sum` the explicit control function
`Φ(a,b) = a + b`), and closed the loop with the pipeline theorems
`rips_height_domination` and `rips_height_shift`, instantiated on `ℚ` via
`dArith`.

## Results Summary

| Result | Statement |
|---|---|
| `ripsGraphF_mono_of_dist_le` | pointwise distance domination ⇒ Rips-edge inclusion |
| `ripsGraphF_shift_of_dist_le_add` | `d₁ ≤ d₂ + ε` ⇒ `ripsGraphF d₂ r ⊆ ripsGraphF d₁ (r+ε)` |
| `tropMax_ultra` | abstract tropical-max ultrametric inequality from the valuation axioms |
| `heightUltra_ultra` | the arithmetic height ultranorm is a genuine ultrametric |
| `heightUltra_le_sum` | computable control `heightUltra h x y ≤ h x + h y` |
| `rips_height_domination` | height domination ⇒ nested Rips filtrations |
| `rips_height_shift` | height-gap bound `δ` ⇒ filtration nested after radius shift `δ` |

A key correction: the informal concept stated the domination/shift directions
backwards. Because the Rips adjacency `d x y ≤ r` is a *sublevel set*, the edge
set is **antitone** in the metric; the proved statements use the mathematically
correct orientations and the file documents the fix.

All results compile with `sorry = 0` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Bold, Falsifiable Research Directions

### 1. Bottleneck stability from arithmetic height gaps

Upgrade the graph-level (π₀) `rips_height_shift` to a genuine *bottleneck
stability* bound on persistence diagrams: a height-gap `‖h₁ − h₂‖∞ ≤ δ` should
force the bottleneck distance between the two persistence modules of the Rips
filtrations to be `≤ δ`. **The key insight is** that `heightUltra_shift` already
proves the two ultranorms are `δ`-interleaved as functions, and interleaving of
filtrations is exactly the hypothesis of the algebraic stability theorem — so the
combinatorial shift lemma is the `H₀` shadow of a full interleaving. *Why now?*
The interleaving inequality is already formalized here as a clean `∀ x y`
pointwise bound, so the remaining work is purely the persistence-module algebra;
no new arithmetic input is required. Falsifiable: it fails if the induced
sublevel filtrations are not `δ`-interleaved as persistence modules, which can be
checked on a 3-point rational cloud by direct computation.

### 2. Northcott finiteness ⇒ eventual constancy of the filtration

Conjecture: for `dArith` on `ℚ`, the number of distinct Rips graphs
`{ripsGraphF dArith r : r ∈ ℝ}` over any height-bounded finite point set is
finite and the filtration stabilizes at `r = max-height`. **The key insight is**
that `heightUltra` takes values in the finite set `{0} ∪ {max(h x, h y)}`, so the
filtration is a step function with breakpoints exactly at attained heights — a
direct topological-data-analysis avatar of Northcott's finiteness theorem. *Why
now?* `ratArithHeight_pos` and the discreteness of `ℕ`-valued heights are already
in the catalog, and `coveringNumber_le_card` gives the matching finite-cover
bound; the proof is a finiteness argument over the image of `heightUltra`.
Falsifiable: exhibit a height-bounded rational cloud whose Rips filtration has
infinitely many distinct graphs.

### 3. Abstract ultranorm filtration over a general `TropicalValuationObject`

Generalize `heightUltra` from ℝ to an order-valued ultranorm landing in an
arbitrary `TropicalValuationObject R`, and define a Rips filtration indexed by
`R` itself (using `GeneralizedFiltration` from `MetricFiltration.lean`). **The
key insight is** that `tropMax_ultra` already proves the strong triangle
inequality *without leaving `R`*, so the entire monotonicity/stability theory
transfers verbatim to the order of the valuation object, removing the detour
through ℝ. *Why now?* `GeneralizedFiltration` is indexed by an arbitrary
`Preorder`, and `TropicalValuationObject` supplies exactly a linear order with a
compatible `max`; the two structures are ready to be glued. Falsifiable: the
transfer breaks if `max_least`/`max_le_left` are insufficient to prove
order-valued monotonicity, i.e. if some non-`ℝ` valuation object yields a
non-monotone filtration.

### 4. VC-dimension of arithmetic Rips graphs

Conjecture: the family of Rips graphs `{ripsGraphF dArith r}_{r}` on `n` rational
points has VC-dimension `O(log H)` where `H` is the maximum height, linking this
file back to `ArithmeticVCDimension.lean`. **The key insight is** that each Rips
graph is determined by a single threshold against the finite set of attained
ultranorm values, so the shattering capacity is controlled by the number of
distinct heights — precisely the height-stratified trace-counting argument of the
VC-dimension file. *Why now?* The VC pipeline (`height control ⇒ finite traces ⇒
bounded shattering`) already exists in the catalog; this direction feeds it the
new geometric family produced here. Falsifiable: construct rational points whose
arithmetic Rips family shatters a set larger than `c · log H`.

### 5. Lipschitz transfer of the height ultranorm to certified robustness

Connect `heightUltra_shift` to the functorial Lipschitz/bound-transfer theorems
of `CategoricalTropicalUltrametric.lean` (e.g.
`lipschitz_certified_robustness_transfer_quantum`): a perturbation of arithmetic
parameters bounded by `δ` should yield a certified `δ`-robustness margin for the
induced ultranorm classifier. **The key insight is** that
`heightUltra_shift` is itself a `1`-Lipschitz (additive) bound transfer, the same
shape the tropical→ultrametric functor consumes, so the arithmetic perturbation
slots directly into the existing certified-robustness machinery. *Why now?* The
bound-transfer functor and our additive shift lemma share an interface
(`d₂ ≤ d₁ + δ`); only the adapter remains. Falsifiable: it fails if the ultranorm
classifier's decision boundary can move by more than `δ` under a `δ`-bounded
height perturbation, testable on explicit rational thresholds.
