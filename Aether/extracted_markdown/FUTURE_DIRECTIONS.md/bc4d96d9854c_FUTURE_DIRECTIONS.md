# Future Directions — Functorial Tropical Valuation Objects from Certificate Data

Derived from the cycle producing `Tropical/MinPlusValuationObject.lean` and
`Bridges/CertificateComplexityValuation.lean`. Each conjecture is falsifiable.

## 1. Exact subadditivity gap measures certificate redundancy
**Conjecture.** For certified key ideals `K₁, K₂`, the defect
`certComplexity K₁ + certComplexity K₂ − certComplexity (composeCert K₁ K₂)`
equals `(K₁.gens ∩ K₂.gens).card`, and this nonnegative gap is a *new*
cryptographic invariant: it is zero iff the two certificates are
generator-disjoint.

The key insight is that the failure of min-plus subadditivity to be an equality
is itself structured data — exactly the overlap of generating certificates — so
the tropical defect quantifies how much two key-generation protocols share.

Why now? `certComplexity_compose_le` already isolates the inequality; Mathlib's
`Finset.card_union_add_card_inter` turns the gap into a clean equality, making
this immediately provable and testable.

## 2. Berggren depth is the unique exact tropical valuation, certificate size is not
**Conjecture.** Among "complexity" valuations into `minPlusTrop`, the Berggren
word-length valuation `bDepth` is characterized (up to scaling) as the unique one
that is an *exact* tropical homomorphism on its monoid, whereas every
certificate-size valuation is strictly subadditive on some composable pair.

The key insight is that monoid gradings (length) tropicalize exactly while
lattice/ideal joins only tropicalize subadditively — so exactness detects whether
the source carries a free-monoid structure versus an idempotent (∪/⊔) structure.

Why now? `bDepth_concat` (exact) and `certComplexity_compose_le` (inequality)
sit side by side in this cycle, exhibiting both regimes; formalizing the
dichotomy only needs a witness pair with overlapping generators.

## 3. Min-plus profiles are functorial under ring homomorphisms
**Conjecture.** A ring homomorphism `f : R → S` induces a map on certificates
(push-forward of generating sets) that is non-increasing for `certVal` in the
trop order, making `certVal` a *functor* from the category of rings-with-
certificates to the min-plus tropical object, compatible with `composeCert`.

The key insight is that image of a span is the span of the image
(`Ideal.map_span`), so certificate complexity can only drop under homomorphic
images — turning the valuation into a contravariant-free, genuinely functorial
tropical invariant rather than a per-ring accident.

Why now? `composeCert_homomorphic` already shows composition preserves FHE
certificates; extending preservation to arbitrary ring maps is the natural next
lemma and unlocks the categorical statement.

## 4. Lorentz complexity refines tree depth and stays tropical
**Conjecture.** Replacing word length by *Lorentz complexity* — e.g. the
base-3 logarithm of the hypotenuse `c` reached along a Berggren word — yields a
valuation that is min-plus subadditive (not exact) under concatenation, with the
defect controlled by the hypotenuse growth bounds (`hypB_upper_bound`,
`iterB_hypotenuse_growth`) of `Algebra/BerggrenLorentz/Core.lean`.

The key insight is that depth counts steps while Lorentz complexity measures
metric growth, and the gap between them is precisely the variability in branch
expansion factors — a tropical valuation whose subadditivity defect encodes
geometric, not combinatorial, information.

Why now? The hypotenuse growth theorems already bound the per-step expansion in
`[3, 7]`, giving explicit two-sided control needed to prove subadditivity with a
quantitative defect.

## 5. Tropical certificate valuations transfer to ultrametric decoding radii
**Conjecture.** Composing `certVal` with the catalog's `valuationReconstruct`
functor (`Bridges/CategoricalTropicalUltrametric.lean`) yields an ultrametric
seminorm on certificate space whose balls are exactly the sets of certificates of
bounded complexity, and min-plus subadditivity becomes the ultrametric strong
triangle inequality.

The key insight is that the reverse-order min-plus object built here is the
order-dual of the catalog's max-based reconstruction target, so the established
"valuation reconstruction is a quantitative functor" principle applies verbatim
to certificate complexity, exporting tropical bounds as certified ultrametric
decoding radii.

Why now? `minPlusTrop` is already an instance of the catalog's
`TropicalValuationObject`, and `valuationReconstruct` already turns such data into
ultrametric norms — the two halves of the bridge are in place and only need to be
composed.
