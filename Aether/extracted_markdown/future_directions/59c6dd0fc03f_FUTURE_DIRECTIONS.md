# Future Directions — Tropical Valuation → Metric Filtration Bridge

Derived from the Phase A cycle that produced
`Bridges/TropicalFiltrationBridge.lean` and
`Bridges/TropicalFiltrationFunctorial.lean`.  Those files turn the catalog's
`UltraNormObj` valuation data (from `Bridges/CategoricalTropicalUltrametric.lean`)
into the `GeneralizedFiltration` language of
`Applications/PoincareData/MetricFiltration.lean`, proving threshold monotonicity,
minimal-radius collapse to `⊥`, global-radius collapse to `⊤`, contravariant
valuation-comparison, post-quantum gap isolation, and a functorial edge transport
`ultraHom_thresholdGraph_hom`.

## C1. Persistence intervals of the ultrametric Rips filtration are dyadic blocks.
The key insight is that the ultrametric strong-triangle law forces the connected
components of `ultraThresholdGraph X r` to be exactly the `r`-balls of the
ultrametric, so the component partition only ever *coarsens* at finitely many
threshold values and never splits — giving a strictly nested, tree-like (dendrogram)
persistence module with no "births after deaths".
*Why now?* `genThresholdGraph_monotone` and `genThresholdGraph_comparison` already
pin down the lattice of stages; the missing step is identifying components with
ultrametric balls, which the existing `norm_add` axiom makes purely combinatorial.

## C2. The induced stage-homomorphism functor is faithful exactly on separated objects.
The key insight is that `ultraHom_thresholdGraph_hom` discards no information when the
target is `UltraSeparated`: two sub-preserving injective morphisms that agree on all
filtration edges must agree as functions, because separation lets the radius-0 graph
detect equality.
*Why now?* We already proved edge transport is radius-uniform
(`ultraHom_thresholdGraph_hom_toFun`) and that separation collapses the radius-0 stage
to `⊥` (`ultraThresholdGraph_bot`); combining them should yield faithfulness.

## C3. Gap isolation is a sharp threshold, not just a bound.
The key insight is that a `PostQuantumGapWitness` makes the secret isolated for every
radius `< gap` **and** non-isolated at radius `= gap` whenever a nearest neighbour
realising the gap exists — so `gap` is the exact birth scale of the secret's edge.
*Why now?* `gap_witness_isolated` gives one direction; the converse needs only an
existence hypothesis (a witness `y` with `ultraVdist = gap`), which is a mild
strengthening of the catalog's `PostQuantumGapWitness` structure.

## C4. Valuation comparison induces an interleaving of persistence modules.
The key insight is that if `d₁ ≤ d₂ ≤ d₁ + c` pointwise, then
`genThresholdGraph_comparison` upgrades to a `c`-interleaving of the two threshold
filtrations, so the bottleneck distance of their persistence diagrams is at most `c`.
*Why now?* The contravariant comparison law is already formalized; an additive slack
`c` turns the one-sided inclusion into the two-sided shift that defines an
interleaving, connecting directly to the catalog's `BoltzmannBridge` interleaving
files.

## C5. The tropical-carrier pipeline is a (lax) monoidal functor for the product valuation.
The key insight is that products of `TropicalValuationCarrier`s with the max-of-norms
valuation map to products of filtrations whose stage at radius `r` is the *categorical
product* of the factor stages — making `tropicalCarrierFiltration` compatible with the
tropical multiplicative structure `norm_mul`.
*Why now?* `valuationReconstruct` is already a functor in the catalog and
`tropicalCarrierFiltration` is its filtration extension; the only new ingredient is the
product carrier, whose valuation axioms follow from `max`/`+` arithmetic already used
throughout `CategoricalTropicalUltrametric.lean`.
