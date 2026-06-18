# Future Directions — Tropical Geometry of ReLU Networks (MachineLearning)

This cycle proved that **arbitrary-depth, equal-width feed-forward ReLU networks
compute tropical rational functions in every output coordinate**
(`Catalog/MachineLearning/TropicalReLUDeep.lean`), upgrading the catalog's
one-hidden-layer bridge (`TropicalReLUBridge.lean`) to the full Zhang–Naitzat–Lim
correspondence. The proof factored through showing that the class `IsTropRational`
is a **lattice-ordered ℝ-vector space closed under ReLU** (closed under `+`, `−`,
arbitrary real scaling, `max`, `min`, `relu`), and that every such function is
continuous. The following conjectures are concrete, falsifiable next steps.

## C1. Converse / exactness of the bridge
**Conjecture.** Every continuous piecewise-linear function `f : ℝ^d → ℝ` with
finitely many linear pieces is tropical rational, and conversely. Hence
`IsTropRational = CPWL_fin`, giving an *exact* characterization of the functions
representable by ReLU networks.
*Test:* formalize `CPWL_fin` (finite affine atlas) and prove
`IsTropRational f ↔ CPWL_fin f`. The `←` direction needs that finitely many
linear pieces can be re-expressed as a `max` minus a `max`; the `→` direction is
already implicit in continuity + the explicit `sup'` form.

## C2. Depth-vs-width region growth is super-additive
**Conjecture.** Let `N(f)` be the number of distinct linear regions (maximal
domains of linearity) of a tropical rational `f`. Then for the depth-`L`,
width-`w` model, `N` can grow like `Ω(w^L)` while any depth-1 network of the
same parameter count realizes only `O(w^d)` regions — a provable, formal
depth-separation in the tropical region count.
*Test:* define `linearRegionCount` via the partition induced by the active set of
maximizing affine pieces of `max(p,q)`; prove a lower bound for an explicit
"sawtooth" weight family by induction on `L`.

## C3. Lipschitz constant = tropical coefficient spread
**Conjecture.** A tropical polynomial `p = sup' {⟨a_i,·⟩+b_i}` is globally
`(max_i ‖a_i‖)`-Lipschitz, and a tropical rational `p − q` is
`(max_i ‖a_i‖ + max_j ‖a'_j‖)`-Lipschitz. Consequently a depth-`L` ReLU readout
is Lipschitz with constant bounded by the product of layer operator norms.
*Test:* prove `IsTropPoly.lipschitzWith` from `Continuous.finset_sup'` +
`LipschitzWith.max`, then chain through `reluLayerFns`. This sharpens the
`tropicalScore_lipschitz` 1-Lipschitz lemma in `MulticlassMargin.lean` to a
network-wide certificate.

## C4. Tropical decision boundaries are polyhedral complexes of bounded degree
**Conjecture.** The decision boundary `{x | p x = q x}` of a depth-`L` width-`w`
tropical-rational classifier is a finite union of polyhedra whose count is
bounded by an explicit function of `(w, L)`; in particular it has measure zero
and is a tropical hypersurface (extending
`decisionBoundary_on_tropHypersurface`).
*Test:* formalize the polyhedral-complex structure of `{max(p,q) attained twice}`
and prove `volume (decisionBoundary f) = 0` for `IsTropRational f`.

## C5. Composition closure ⇒ residual / skip-connection invariance
**Conjecture.** `IsTropRational` is closed under composition with affine maps on
the *input* and under residual connections `x ↦ x + ReLU(Wx+b)`; therefore any
ResNet-style architecture (not just plain MLPs) also computes tropical rational
functions. The equal-width restriction in this cycle is inessential.
*Test:* prove `IsTropRational.comp_affine` and a residual-block closure lemma,
then redefine `deepReLUNetFns` with variable widths via `Fin`-indexed layers and
re-derive `deepReLUNetFns_isTropRational` in the general setting.
