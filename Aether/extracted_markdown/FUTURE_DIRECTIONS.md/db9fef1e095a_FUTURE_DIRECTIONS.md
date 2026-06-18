# Future Directions — Rips ↔ Tropical Valuation Bridge (cycle output)

This cycle built and verified the missing **anchor** of the program:

* `Catalog/Geometry/RipsTropicalCompletion.lean` — `tropBirthSum`, the exact completion
  threshold `ripsGraph α ε = ⊤ ↔ tropBirthSum α ≤ ε`, minimality (`IsLeast`), the literal
  `Tropical ℝᵒᵈ` functional with additivity over unions, and functoriality along
  nonexpanding surjections / isometric embeddings.
* `Catalog/Geometry/RipsTropicalStability.lean` — sharp 1-Lipschitz stability of the
  threshold under metric perturbation, with an explicit tightness witness.
* `Catalog/Geometry/RipsCliqueCompletion.lean` — the *higher-dimensional* completion
  threshold: the full Vietoris–Rips complex becomes the full simplex at exactly
  `tropBirthSum α` (`cliqueComplex G = fullComplex ↔ G = ⊤`), plus the per-face birth
  criterion.

The conjectures below are derived from this cycle's findings (Stage 3 / Stage 4 notes in
each file) and are bold and falsifiable.

## Conjecture 1 — The whole persistence barcode is a multiset of max-plus face folds

For a finite metric space, the death scale of *every* face of the Vietoris–Rips complex is
the internal max-plus birth fold `faceBirth s = sup_{x≠y∈s} dist x y`, and the full
`k`-skeleton completes at `max` of these over all `(k+1)`-subsets. **Conjecture:** the entire
multidimensional `f`-vector profile `ε ↦ (f_0, f_1, …)` is reconstructible from the multiset
`{faceBirth s}` alone.

* **The key insight is** that `mem_vietorisRips_dist_iff` already proves each face is born
  exactly at its internal max-plus fold, so the barcode is a bookkeeping of these folds
  rather than new homological data.
* **Why now?** The face criterion and `cliqueComplex_eq_full_iff` are formalized this cycle,
  so the per-face fold is available; only the indexing over `powersetCard` (already used in
  `CliqueComplexFlag.fVector`) remains.

## Conjecture 2 — `tropBirthSum` is a semiring homomorphism, not just a monoid map

The additivity `tropBirthSumT_union` makes the fold a max-plus *additive* map. **Conjecture:**
extending the source to the face semiring (union = ⊕, concatenation of vertex sets = ⊗)
turns `tropBirthSumT` into a genuine `Tropical ℝᵒᵈ`-semiring homomorphism, so every
completion corollary upgrades to a homomorphism statement.

* **The key insight is** that `trop_toDual_max` realizes `max` as literal tropical `+`, so
  the only missing piece is a multiplicative law identifying simplex *joins* with tropical
  product.
* **Why now?** Mathlib's `Tropical` and the project's min-plus algebra are verified, and
  `tropBirthSumT` is already a definitional bridge (`untrop_tropBirthSumT`), so the algebraic
  upgrade is structural.

## Conjecture 3 — Threshold stability implies bottleneck stability of completion modules

The sharp bound `tropBirthSumOf_stability` says the threshold is 1-Lipschitz in the
sup-distance of metrics. **Conjecture:** the persistence module "is the 1-skeleton complete?"
has bottleneck distance `≤ δ` whenever the metrics are within `δ`, i.e. the completion
feature is bottleneck-stable with the *same* constant.

* **The key insight is** that a single-feature module is determined by one threshold, so its
  bottleneck distance collapses to `|tropBirthSum d − tropBirthSum d'|`, which is `≤ δ` and
  tight by `tropBirthSumOf_stability_tight`.
* **Why now?** `InterleavingMetric`, `BottleneckStability`, and `PersistenceStability` are
  already in the Boltzmann-bridge arc, so the Lipschitz bound plugs into existing vocabulary.

## Conjecture 4 — The completion region is an up-set in the multiparameter poset

For a multiparameter Rips filtration indexed by `(density, distance)`, define the joint
completion threshold by folding `tropBirthSum` over the parameter poset. **Conjecture:** the
set of parameters at which the complex is complete is a monotone up-set, and `tropBirthSum`
is the unique minimal corner along each axis.

* **The key insight is** that `tropBirthSum_le_of_nonexpanding_surjective` and
  `tropBirthSum_le_of_isometry` already make the threshold monotone/functorial in exactly
  the directions a parameter increase moves it.
* **Why now?** Both the functorial edge-count API (`RipsFunctorialEdgeCount`) and the
  single-parameter threshold are formalized, so the multiparameter statement is an indexing
  of existing folds.

## Conjecture 5 — A kernel-checked `O(n²)` completion certifier over ℚ

**Conjecture:** over `ℚ`-valued dissimilarities, `tropBirthSum` is a computable single
`Finset.sup'` fold, and a decision procedure "is `ripsGraph` complete at scale `ε`?" can be
implemented with a `@[csimp]`-justified efficient fold whose correctness is exactly
`ripsGraph_eq_top_iff_tropBirthSum_le`.

* **The key insight is** that the whole pipeline is one `O(n²)` tropical fold followed by a
  single comparison, and the correctness lemma is already proved (no `sorry`).
* **Why now?** The decision content is isolated into the threshold equivalence this cycle, so
  only making the `ℚ`-fold computable and wrapping it remains.
