# Future Directions — Valuation-Depth ↔ Tropical Filtration Bridge

## Synthesis

This cycle built a new arithmetic-to-tropical pipeline in
`Catalog/Bridges/ValuationDepthTropicalFiltration.lean`. It takes the p-adic
arithmetic depth functional `vdepth : (α → β) → ℕ` from
`Computation/PadicValuationDepth.lean` and exhibits it as a *monotone tropical
weight*, then connects the resulting structure to the tropical valuation objects of
`Bridges/CategoricalTropicalUltrametric.lean`.

The conceptual core is a single sign flip: setting `dcost f = -(vdepth f)` turns the
carry-free bound `vdepth (f+g) ≤ max (vdepth f) (vdepth g) + 1` (`vdepth_sum_le`) into
a min-plus subadditivity statement `min (dcost f) (dcost g) - 1 ≤ dcost (f+g)`. The
`+1` is an explicit *unit defect*, and it reappears verbatim as the shift/Lipschitz
constant in the stability theorems. Thus the additive-defect parameter and the
filtration-shift parameter are literally the same number.

## Results Summary

* **Normalization.** `Filt_zero` (`Filt 0 = univ`), `const_weight_zero` and
  `dcost_const_zero` (the zero function has tropical zero cost), built on
  `vdepth_const_eq_zero`.
* **Tropical subadditivity.** `dcost_subadditive` (min-plus subadditivity up to unit
  defect), `cost_sublevel_add` (cost sub-level closure, the tropical face of
  `ValDepthClassSet.add_mem_succ`), and `weight_subadditive_tropicalBase`, which reads
  the bound inside the catalog's `tropicalization_base.max_op`.
* **Filtration geometry.** `Filt_subset_of_le` and `Filt_succ_subset` (antitone),
  `iInter_Filt_eq_empty` (separated/exhaustive), `const_zero_notMem_Filt_succ`.
* **Depth-controlled morphisms.** `DepthDefectMap` with `id` and `comp` (defects add),
  a category-like package graded by the defect parameter.
* **Stability (headline).** `DepthDefectMap.maps_Filt` (a defect-`ε` map shifts the
  filtration by at most `ε`), `DepthDefectMap.cost_nonexpansive` (`ε`-nonexpansive on
  cost), and `DepthDefectMap.maps_Filt_of_zero` / `cost_eq_of_zero` (defect-free maps
  preserve every stratum and are exact isometries).

All main results compile with `sorry = 0` and depend only on
`propext`, `Classical.choice`, `Quot.sound`.

## Bold, Falsifiable Directions

### 1. Persistence module / barcode of the depth filtration
Promote the antitone family `n ↦ Filt n` to a genuine persistence module over `ℕ` and
prove that a `DepthDefectMap` of defect `ε` induces an `ε`-interleaving, so the induced
barcodes are `ε`-close in bottleneck distance. *The key insight is* that
`DepthDefectMap.maps_Filt` already is an interleaving morphism in disguise — the shift
`n ↦ n - ε` is exactly the interleaving shift, so stability of barcodes should follow
formally from the shift bound. *Why now:* the catalog has `SheafPersistence` and
`PersistentHomology/Theorems`; bolting depth filtrations onto that machinery would unify
the p-adic side with the existing persistence bridges. Falsifiable: exhibit a defect-`ε`
map whose induced barcode moves by more than `ε`, and the conjecture dies.

### 2. Exact depth on a concrete non-trivial instance
The only concrete `ValuationDepthMeasure` instance in the catalog is the trivial
`vdepth ≡ 0` on `ℕ`. Build a non-degenerate instance (e.g. depth = number of
multiplication/addition rounds to synthesize a polynomial map, or `vdepth f =`
something read off `PadicInt` valuations) and prove a *strict* hierarchy
`Filt n ⊋ Filt (n+1)` via a `DepthWitness`. *The key insight is* that
`strict_hierarchy_from_witness` already reduces strictness to producing one function of
each exact depth, so the entire open problem collapses to constructing witnesses on a
real instance. *Why now:* every quantitative theorem here is vacuous-resistant only once
a non-trivial instance exists; this is the highest-leverage gap. Falsifiable: if every
candidate instance forces `vdepth` to collapse (all depths equal), the filtration is
trivial and the program stalls.

### 3. Multiplicative (graded-ring) refinement
`vdepth_mul` gives `vdepth (f·g) ≤ max + 1` as well, so `dcost` should be sub-*multiplicative*
in the tropical (min-plus) sense, making `⨁ Filt n` behave like a filtered/graded ring
with `Filt m · Filt n ⊆ Filt (min(m,n) - 1)` on the cost side. *The key insight is* that
addition and multiplication obey the *same* `max + 1` law, so a single graded-ring
statement subsumes both `dcost_subadditive` and its multiplicative analogue. *Why now:*
the catalog's `RingTheoryBridge` and `tropicalization_base` already carry a multiplicative
layer (ordinary `*` on ℕ); connecting the depth grading to it would yield a tropical
filtered-algebra theorem. Falsifiable: find functions where the product's depth exceeds
the predicted graded bound.

### 4. Composition / iteration stability via `UltrametricCompositionLaw`
`Computation/PadicValuationDepth.lean` has `vdepth_comp` and `vdepth_iterate_succ`. Define
`DepthDefectMap`s arising from composition with a fixed kernel and prove that *iterating*
a defect-`ε` map `k` times gives a defect-`kε` map (so filtration shift grows linearly,
not exponentially — the carry-free analogue of `iter_exponent_stable`). *The key insight is*
that `DepthDefectMap.comp` already proves defects add, so iteration stability is just
induction over `comp`. *Why now:* this mirrors the catalog's ultrametric robustness
results (`iter_exponent_stable`, `lipschitz_gap_exponential`) but on the depth-filtration
side, giving a clean classical-vs-ultrametric gap statement. Falsifiable: produce a map
whose `k`-fold iterate has defect super-linear in `k`.

### 5. Functor into the categorical tropical framework
Package `DepthDefectMap` morphisms as honest `TropHom`/`UltraHom`-style arrows so that
`f ↦ (Filt-data of f)` becomes a functor landing in the categories of
`Bridges/CategoricalTropicalUltrametric.lean`, with `cost_nonexpansive` realizing the
`norm_nonexpansive'` field of `UltraHom`. *The key insight is* that `dcost` is already a
seminorm-like weight and `cost_nonexpansive` is already the nonexpansiveness axiom — only
the bundling into `UltraNormObj`/`UltraHom` is missing. *Why now:* the categorical scaffold
(identity, composition, functoriality laws) is fully proved in the catalog, so the functor
laws should transfer with minimal new work. Falsifiable: if no choice of underlying
additive structure makes the depth data satisfy `UltraNormObj.norm_add`, the functorial
packaging is impossible and a weaker (lax) formulation is forced.
