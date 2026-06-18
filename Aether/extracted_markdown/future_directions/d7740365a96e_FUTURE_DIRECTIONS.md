# Future Directions — Quantitative Myhill–Nerode Compression

File produced this cycle: `Catalog/Bridges/QuantitativeMyhillNerodeCompression.lean`
(extends `Catalog/Bridges/CoalgebraicNeuralMyhillNerode.lean`).

## Synthesis

This cycle built the missing *quantitative* layer on top of the existing coalgebraic
neural Myhill–Nerode framework. The catalog already had a purely qualitative behavioral
equivalence `neural_equiv` and its quotient (with universal property, uniqueness, and a
state-count bound). The key structural insight discovered here is that the **shortest
distinguishing context** gives a canonical tropical / min-plus *valuation depth*
`sepDepth N s t : ℕ∞`, and that this is not merely a metric bolted on by hand: its
ultrametric structure is *forced* by the coalgebraic congruence. Concretely, the strong
triangle inequality `min (sepDepth s t) (sepDepth t u) ≤ sepDepth s u` is exactly the
quantitative shadow of the (qualitative) transitivity of finite-depth agreement, and
`sepDepth = ⊤ ⇔ neural_equiv` ties the valuation to the existing equivalence.

The most important emergent fact is that **every coalgebra morphism is an isometry** for
this codistance (`neuralHom_isometry`), because morphisms preserve all behaviors. This is
strictly stronger than the requested "nonexpansive" property and makes the nonexpansiveness
of the Myhill–Nerode projection a one-line corollary. It also upgrades the catalog's
qualitative universal property to a quantitative one: the factoring map through the quotient
is itself an isometry (`quotient_quantitative_universal`), and the quotient is a genuine
*separated* ultrametric space (`qSepDepth_eq_top_iff`) — distinct compressed states are never
at codistance `⊤`. Together these exhibit the Myhill–Nerode quotient as the terminal
nonexpansive observation-preserving compression.

What did *not* work / what we deliberately avoided: a real-valued `2^(-depth)` ultrametric
forces `sInf`/analysis bookkeeping for every lemma. Re-casting the distance as a min-plus
codistance in the complete lattice `ℕ∞` kept all proofs lattice-theoretic (`iInf_eq_top`,
`le_iInf₂`, `iInf₂_le`) and made the empty-distinguisher (`⊤`) case automatic, eliminating
any partiality of `Nat.find`. The honest subtlety, flagged in the title's framing, is that
the *additive* triangle inequality is false; only the tropical `min` law holds — which is
precisely the ultrametric signature.

## Results Summary

- `distinguishers` / `sepDepth`: definitions — tropical observation codistance via shortest distinguishing word in `ℕ∞`.
- `distinguishers_symm`, `sepDepth_symm`: proved — symmetry of the codistance.
- `distinguishers_congr`: proved — distinguisher sets depend only on behavior, enabling descent to the quotient.
- `sepDepth_self`: proved — a state is at codistance `⊤` from itself.
- `sepDepth_eq_top_iff`: proved — codistance `⊤` characterises behavioral equivalence exactly.
- `sepDepth_strong_triangle`: proved — the tropical/ultrametric strong triangle inequality (headline result).
- `neuralHom_distinguishers`: proved — morphisms preserve distinguisher sets.
- `neuralHom_isometry`: proved — every coalgebra morphism is a codistance isometry.
- `neuralHom_nonexpansive`: proved — morphisms are nonexpansive (corollary of isometry).
- `sepDepth_quotient_system`: proved — the Myhill–Nerode projection preserves codistance exactly.
- `quotient_projection_nonexpansive`: proved — the projection is 1-Lipschitz/nonexpansive.
- `qSepDepth` / `qSepDepth_mk`: definition + computation rule — codistance descended to the quotient.
- `qSepDepth_eq_top_iff`: proved — the quotient is a separated ultrametric space (quantitative minimality).
- `qSepDepth_strong_triangle`: proved — strong triangle inequality on the compressed states.
- `quotient_quantitative_universal`: proved — observation-preserving morphisms factor *isometrically* through the quotient.

All theorems compile with no `sorry` and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### Direction 1: Real-valued ultrametric realization and the Lipschitz constant
**Hypothesis**: For any `0 < c < 1` the map `d N s t = c ^ (sepDepth N s t)` (with `c^⊤ = 0`)
is an honest pseudo-ultrametric `d : σ → σ → ℝ≥0`, a genuine metric on the quotient, and the
projection is `1`-Lipschitz with `d (proj s) (proj t) = d s t`.
**Test**: Define `d` into `ℝ≥0` (or `ℝ≥0∞`), prove `d s u ≤ max (d s t) (d t u)` from
`sepDepth_strong_triangle` by monotonicity of `x ↦ c^x`, and `d s t = 0 ↔ neural_equiv`.
**Why now**: `sepDepth_strong_triangle` and `sepDepth_eq_top_iff` already package every fact
the real-valued statement needs; only an order-reversing transfer lemma is missing.
**If true**: connects this development to Mathlib's `PseudoMetricSpace`/`EMetricSpace` API and
the catalog's `MetricSpaceBridge`, giving certified robustness bounds in standard metric form.
**If false**: would reveal that the codistance is genuinely "more tropical than metric" — a
sign that the right target category is `ℕ∞`-enriched (Lawvere) rather than `ℝ`-metric.

### Direction 2: Lawvere/quantale enrichment and a generalized codistance
**Hypothesis**: `sepDepth` is the hom-object of a `(ℕ∞, min, +)`-enriched category structure
on states, so that "nonexpansive" = enriched functor; replacing `ℕ∞` by an arbitrary
ordered idempotent quantale `Q` (à la `CategoricalTropicalUltrametric.TropObj`) yields a
`Q`-valued codistance with the same strong triangle and isometry theorems.
**Test**: Abstract `sepDepth` to `⨅ w ∈ distinguishers, V (w)` for a valuation `V : List α → Q`
that is monotone under prefixing, and re-prove `*_strong_triangle` and `neuralHom_isometry`.
**Why now**: the catalog's `TropicalValuationObject` provides exactly the quantale axioms, and
this cycle's proofs only used complete-lattice `iInf` facts that hold in any `TropObj`.
**If true**: produces a single theorem schema covering tropical, ultrametric, and Boolean
(qualitative) Myhill–Nerode at once — the cross-domain bridge the concept asked for.
**If false**: pinpoints which lattice axiom (idempotency? completeness?) the isometry theorem
truly needs, sharpening the hypotheses.

### Direction 3: Finite-depth computability and a certified minimization budget
**Hypothesis**: When `α` is finite and `β` has decidable equality, `sepDepth N s t` is computable
and equals `⨅ w ∈ {w | w.length ≤ K} ∩ distinguishers, w.length` for a finite `K` bounded by the
number of states, recovering an `O(|α|^K)` minimization algorithm whose output is certified
codistance-minimal by `qSepDepth_eq_top_iff`.
**Test**: Connect `sepDepth` to the catalog's `neural_equiv_upto` / `observation_signature_upto`
and prove `sepDepth N s t = k ↔ (neural_equiv_upto N (k-1) s t ∧ ¬ neural_equiv_upto N k s t)`,
then bound `k` by `Fintype.card σ` using `finite_depth_refinement_stabilizes_sufficient`.
**Why now**: the catalog already proves finite-depth stabilization and a state-count bound; this
cycle's `sepDepth` is the natural numeric witness those qualitative results were missing.
**If true**: yields a verified partition-refinement minimizer with an explicit codistance budget.
**If false**: would show the codistance can exceed the qualitative stabilization depth, i.e. fine
metric structure persists beyond where the equivalence relation stabilizes.

### Direction 4: Strict contraction under lossy observation and a quantitative data-processing inequality
**Hypothesis**: If `g : β → β'` is a (possibly lossy) post-processing of observations and `N'` is
`N` with `observe := g ∘ N.observe`, then `sepDepth N' s t ≥ sepDepth N s t` for all `s,t`
(post-processing can only increase codistance / decrease distinguishability), with equality iff
`g` is injective on the reachable observation set.
**Test**: Show `distinguishers N' s t ⊆ distinguishers N s t` and take `iInf` monotonicity; for the
equality clause use injectivity of `g`.
**Why now**: `neuralHom_isometry` shows *state* maps are isometries; the dual question for
*observation* maps is the natural completion and uses the same `distinguishers` machinery.
**If true**: a Myhill–Nerode analogue of the information-theoretic data-processing inequality,
bridging to the catalog's `FisherMonotonicity`/`LocalityCorrelation` files.
**If false**: would expose a non-monotone post-processing, a genuine counterexample worth isolating.

### Direction 5: Product systems and an additive/tropical tensor law for codistance
**Hypothesis**: For the product system `product_neural_system N M`, the codistance satisfies
`sepDepth (N×M) (s,s') (t,t') = min (sepDepth N s t) (sepDepth M s' t')` (the shortest word that
distinguishes either component distinguishes the pair).
**Test**: Relate `distinguishers` of the product to the union of component distinguishers (using
the catalog's `product_behavior_components`) and compute the `iInf`.
**Why now**: the catalog defines `product_neural_system` and proves `product_behavior_components`
and `product_equiv_implies_component_equiv`, the exact ingredients for the codistance computation.
**If true**: gives a compositional (monoidal) law making `sepDepth` a lax/strong monoidal functor
on the category of observation systems — a structural compositionality theorem for compression.
**If false**: identifies cross-component interactions that break naive compositional minimization,
informing how products must be minimized jointly rather than factorwise.
