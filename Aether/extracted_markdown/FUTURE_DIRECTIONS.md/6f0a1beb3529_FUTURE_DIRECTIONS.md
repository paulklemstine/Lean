# Future Directions — Tropical ↔ Computation Depth Comparison

## Synthesis

`Catalog/Bridges/TropicalPadicDepthComparison.lean` installs the first explicit
comparison interface joining three catalog domains: the Bridges/Tropical object
language of `CategoricalTropicalUltrametric` (`UltraNormObj`, `UltraHom`, the
`ℕ`-valued ultrametric height `norm`) and the Computation-side
`ValuationDepthMeasure` API (`vdepth`, `vdepth_const_eq_zero`, `vdepth_sum_le`,
`vdepth_prod_le`, `ValDepthClassSet`).

The bridge is a *realization functor*. A `DepthRealization` sends each element of a
tropical valuation object to a function whose valuation depth we can measure,
translating tropical zero/sum/product into pointwise zero/sum/product. On top of it,
a `DepthCompatible` realization carries a single domination axiom
`depth_le_height : vdepth (realize x) ≤ X.norm x`. From these we proved, with **zero
sorries and zero extra axioms**:

* **Normalization** (`rdepth_zero`) — realized depth of the tropical zero is `0`,
  exactly mirroring `vdepth_const_eq_zero`.
* **Subadditivity** (`rdepth_add_le`, `rdepth_mul_le`) — realized depth of a tropical
  sum/product is `≤ max(parts) + 1`, mirroring `vdepth_sum_le` / `vdepth_prod_le`.
* **1-Lipschitz depth monotonicity** (`rdepth_le_norm`, `ddepth_le_source_dist`) —
  the induced depth pseudodistance is dominated by the source ultrametric distance.
* **Certificate transport** (`realize_mem_class`) — a tropical height bound
  `norm x ≤ k` certifies membership in the valuation-depth class `VAL_k`.
* **Functoriality** (`DepthCompatible.pullback`, `rdepth_pullback`,
  `rdepth_pullback_le_norm`, `rdepth_pullback_comp`) — every `UltraHom` pulls a
  `DepthCompatible` back contravariantly, and pullback is strictly functorial under
  composition; the comparison bound is preserved by pullback.

The conceptual message: tropical height and valuation depth are not merely
analogous — there is an honest, structure-preserving, nonexpansive comparison map
between them, and it is functorial.

## Results Summary

| Theorem | Content | Axioms |
|---|---|---|
| `rdepth_zero` | normalization to `0` | none |
| `rdepth_add_le` | sum subadditivity | none |
| `rdepth_mul_le` | product subadditivity | none |
| `ddepth_le_source_dist` | 1-Lipschitz comparison | none |
| `realize_mem_class` | tropical cert ⟹ `VAL_k` | none |
| `rdepth_pullback_comp` | functoriality | none |

## Research Directions

### 1. A genuine contravariant functor into the category of depth measures

Right now functoriality is stated pointwise on `rdepth`. The natural next step is to
package `X ↦ {DepthCompatible X α β}` and `f ↦ DepthCompatible.pullback f` as a
bona fide contravariant functor from the `UltraHom` category to a category of
"depth-comparison data", and prove the identity law `pullback (UltraHom.id X) R = R`
alongside the composition law we already have. **The key insight is** that the
realization map is itself a morphism in a comma category, so the functor laws should
reduce to the already-proven `UltraHom.comp_assoc` / `UltraHom.id_comp` plus
`DepthRealization` extensionality. **Why now?** The category laws for `UltraHom` are
already in `CategoricalTropicalUltrametric`, so the only missing ingredient is an
`@[ext]` lemma for `DepthCompatible`, which is mechanical — this converts a pointwise
result into a structural categorical statement with little new risk.

### 2. Sharpness: a depth witness whose tropical height is exactly attained

Our comparison is an inequality `rdepth ≤ norm`. The falsifiable conjecture is that
it is *tight*: there exists an `UltraNormObj X`, a `DepthCompatible` realization, and
an element `x` with `rdepth R x = X.norm x`, and moreover a `DepthWitness`-style
family realizing every level of the hierarchy `ValDepthClassSet`. **The key insight
is** that `PadicValuationDepth.DepthWitness` and `strict_hierarchy_from_witness`
already certify strict depth separations, so transporting one witness through a
realization with `norm x = k+1` would pin the inequality to equality. **Why now?**
The witness machinery and the strict-hierarchy theorem already exist in
`Computation/PadicValuationDepth.lean`; the open question is purely whether a
realization can saturate the bound, which is a concrete construction, not new theory.

### 3. Ultrametric (not just dominated) structure on the induced depth distance

We proved `ddepth R x y ≤ X.norm (X.sub_op x y)`. The bolder claim is that `ddepth`
is itself an honest ultrametric pseudometric:
`ddepth R x z ≤ max (ddepth R x y) (ddepth R y z)`. **The key insight is** that this
requires the realization to also respect negation/subtraction
(`realize (sub_op x y) = realize x - realize y` in a suitable sense), turning the
strong triangle inequality for `vdepth` of differences into the strong triangle
inequality for `ddepth`. **Why now?** `UltraNormObj` already exposes `neg_op`,
`sub_op`, and `sub_def`, and `norm_add ≤ max` gives the model to imitate; the only
new hypothesis is a `realize_neg` field, making this a small, testable extension that
either holds for additive realizations or produces an explicit counterexample.

### 4. Composing with the tropicalization functor for a round trip

`CategoricalTropicalUltrametric` defines `tropicalization : UltraNormObj → TropObj`
and a round-trip `roundTrip_norm_preserved`. The conjecture is that depth comparison
is invariant under this round trip: a `DepthCompatible X` and its transport along
`roundTrip` induce equal realized-depth functions. **The key insight is** that
`roundTrip_norm_preserved` already shows the height is unchanged, so any
height-dominated quantity (like `rdepth`) should be invariant for free. **Why now?**
The round-trip preservation lemma is already proven in the catalog, so this direction
tests whether our comparison interface is *coherent* with the existing
tropicalization functor — a clean falsifiable compatibility check.

### 5. From p-adic norms to concrete realizations over `ℤ_[p]`

`PadicValuationDepth` ends with the genuine p-adic facts
`padic_norm_ultrametric`, `padic_dist_ultrametric` on `ℤ_[p]`. The direction is to
build a concrete `DepthCompatible` whose height is (a discretization of) the p-adic
norm, instantiating the abstract bridge on a real non-Archimedean object and turning
`ddepth_le_source_dist` into an explicit p-adic depth bound. **The key insight is**
that the p-adic norm already satisfies the ultrametric law our `UltraNormObj`
abstracts, so the work is to choose an `ℕ`-valued surrogate (e.g. `p`-adic
valuation truncated to a budget) and verify the three realization axioms. **Why now?**
Both endpoints — the abstract comparison and the concrete p-adic ultrametric — are
already formalized in the same project, so wiring them together yields the first
*computable* p-adic instance of the bridge without inventing new analysis.
