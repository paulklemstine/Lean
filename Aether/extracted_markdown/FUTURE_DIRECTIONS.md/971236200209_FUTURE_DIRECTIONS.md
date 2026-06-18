# Future Directions — Functorial Ultrametric Stability of Tropical Valuation Objects on Rips Filtrations

## Synthesis

This cycle built the missing bridge `Applications/PoincareData` ↔ `Bridges/CategoricalTropicalUltrametric`.
The catalog already had both endpoints — monotone Rips filtrations (`ripsGraph`, `ripsGraph_mono`)
on one side, and an abstract category of ultranorm objects (`UltraNormObj`, `UltraHom`, the valuation
reconstruction functor) on the other — but nothing connecting scale-indexed *metric* data to the
*tropical/ultrametric* machinery. The new file `Bridges/RipsTropicalUltrametric.lean` closes the gap
with a complete, sorry-free pipeline:

1. a monotone `ℕ`-valued tropical valuation summary `ripsPairCount` of each Rips level
   (`ripsPairCount_mono` upgrades the graph-inclusion `ripsGraph_mono` to a numeric invariant);
2. an abstract **monotone-to-functor theorem** — every preorder-indexed *antitone* family of
   ultrametric valuations on a fixed carrier yields a functor `ι ⥤ UltraNormObj`
   (`UltraFiltration.ofAntitone`, with proved `map_id`, `map_comp`, single-step `stability`, and
   the cross-scale composition law `stability_trans`); and
3. the **Rips instantiation** `ripsUltraFiltration`, where the monotone pair count is read into the
   exponent of a multiplicative power valuation `n ↦ n ^ (|X|² − ripsPairCount X ε + 1)`, giving a
   genuine `AntitoneValuationFamily ℝ` and the headline stability theorem
   `ripsUltraFiltration_stability`: for `ε₁ ≤ ε₂`, the scale-`ε₂` ultranorm is pointwise `≤` the
   scale-`ε₁` ultranorm.

The conceptual heart of the construction is one inversion: ultranorm morphisms want the norm to *decrease*,
while Rips connectivity *increases* with scale; subtracting the pair count from the fixed bound `|X|²`
and pulling the result through a power valuation turns "more edges" into "smaller ultranorm", which is
exactly the persistence intuition that points merge as the scale grows — now realised functorially
inside the existing ultranorm category.

## Results Summary

| Result | Statement | Status |
|---|---|---|
| `ripsPairCount_mono` | Rips pair count is monotone in scale | proved (no sorry) |
| `ripsPairCount_le` | pair count `≤ |X|²` | proved |
| `ripsAdj_iff` | local predicate = catalog `ripsGraph` adjacency | proved (`rfl`) |
| `UltraFiltration.ofAntitone` | antitone family ⇒ functor into `UltraNormObj` | proved |
| `UltraFiltration.stability` | induced map is norm-nonexpanding | proved (axiom-free) |
| `UltraFiltration.stability_trans` | composition law + chained bound | proved (axiom-free) |
| `ripsUltraFiltration` | the Rips → ultranorm functor | constructed |
| `ripsUltraFiltration_stability(_explicit)` | scale-monotone ultranorm bound | proved |
| `ripsUltraFiltration_comp` | functorial composition for three scales | proved |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Interleaving distance is an ultranorm Lipschitz functor

Two point clouds `X, Y` that are `δ`-close in Gromov–Hausdorff distance should induce ultranorm objects
whose reconstructed norms differ by a bounded multiplicative factor depending only on `δ` and `|X|, |Y|`.
Concretely: build a `UltraLipschitzData (ripsUltraFiltration X .obj ε) (ripsUltraFiltration Y .obj ε)`
whose constant is governed by the number of pairs whose adjacency status flips between `X` and `Y`.
**The key insight is** that the existing `UltraLipschitzData` structure already packages exactly the
multiplicative perturbation bound that a Gromov–Hausdorff `δ`-perturbation produces at the level of
pair counts, so persistence *stability* becomes ultranorm *Lipschitz continuity*. **Why now?** The
catalog's `BoltzmannBridge/PersistenceStability.lean` and `InterleavingIsometry.lean` already formalize
interleavings; this direction would weld that metric-stability theory to the tropical functor built here,
turning the stability theorem from "single space, varying scale" into "varying space, fixed scale".

### 2. The functor factors through `valuationReconstruct` as a natural transformation

`ripsUltraFiltration` produces `UltraNormObj`s directly; but each should arise as
`valuationReconstruct` applied to a Rips-derived `TropicalValuationCarrier`, and the scale maps should be
the image under `valuationReconstruct_map` of carrier morphisms. The falsifiable claim: there is a functor
`R : ℝ ⥤ TropicalValuationCarrier` with `valuationReconstruct ∘ R ≅ ripsUltraFiltration.obj` naturally in
the scale. **The key insight is** that the power valuation `n ↦ n^{e(ε)}` is literally a ring valuation on
the carrier, so the geometric functor should not merely *land in* ultranorm objects but *factor through*
the catalog's reconstruction functor, exhibiting Rips persistence as a special case of valuation
reconstruction. **Why now?** `valuationReconstruct`, `valuationReconstruct_map`, and its functor laws
(`valuationReconstruct_map_id/comp`) are already proven in the catalog; only the natural isomorphism is
missing, and proving it would make the bridge a commuting triangle rather than two parallel constructions.

### 3. Cohomological obstruction to gluing local Rips ultranorms

Cover a finite metric space by overlapping subsets `{X_i}`; each yields a local functor
`ripsUltraFiltration X_i`. These agree on overlaps up to the pair counts shared between patches. The
conjecture: the obstruction to gluing the local ultranorm functors into a single global one on `⋃ X_i`
is measured by a Čech-style `H¹` of the nerve with coefficients in the (additive group generated by)
pair-count discrepancies, and it vanishes iff every cross-patch adjacency is already witnessed inside a
single patch. **The key insight is** that `ripsPairCount` is *not* additive over a cover (it double counts
cross-patch edges), and the exact failure of additivity is a cocycle — a genuinely sheaf-theoretic
local-to-global obstruction living on the Rips nerve. **Why now?** The catalog's `BoltzmannBridge/CechNerve.lean`
supplies the nerve machinery, and this engine is explicitly tuned for obstruction theory; combining them
would produce the first cohomological invariant of a tropical persistence functor.

### 4. Sharpness: the power-valuation exponent is the unique multiplicative carrier of monotonicity

The construction uses `n ↦ n^{e(ε)}`. The falsifiable claim: among all `ℕ`-valued multiplicative
ultranorms on `ℕ` (with `⊔` addition) that are antitone in a scale, *every* one is, up to a fixed
relabelling, a power valuation with antitone exponent — i.e. the exponent route is not a lucky choice but
forced by the `norm_mul = product` axiom of `UltraNormObj`. **The key insight is** that completely
multiplicative `ℕ → ℕ` maps are rigid (determined by their values on primes), so the space of admissible
scale-dependent ultranorms is essentially one-dimensional, pinned by a single antitone exponent function.
**Why now?** This converts the "Failure analysis" note in the lab notebook into a theorem, giving a clean
classification that would justify the design and tell the next cycle exactly which valuations to look for
when instantiating other filtrations (e.g. čech, witness, or sublevel-set complexes).

### 5. Persistence-diagram readout: exponent jumps are the death times of the tropical invariant

Define `criticalScales X = { ε : ε is a discontinuity of ε ↦ ripsExp X ε }`. The conjecture: these are
exactly the pairwise distances of `X`, and the multiset of jump sizes of `ripsExp` reconstructs the
0-dimensional persistence barcode of the Rips filtration. **The key insight is** that the *only* way the
power exponent `|X|² − ripsPairCount X ε + 1` changes is when a new pair becomes adjacent, i.e. exactly at
a pairwise distance, so the analytically simple scalar `ripsExp` already encodes the full event structure
of the filtration. **Why now?** It would turn the tropical ultranorm functor into a *computable* barcode
extractor with a machine-checked correctness statement, directly connecting this bridge back to the
persistent-homology motivation of `MetricFiltration.lean` and giving the next team a concrete, testable
algorithmic deliverable.
