# Future Directions — A Functorial Ultrametric on Tropical Valuation Presentations

## Synthesis

This cycle upgraded the *structural* tropical↔ultrametric bridge of
`Bridges/CategoricalTropicalUltrametric.lean` into a *quantitative* one, with distortion
measured by the arithmetic height `ratArithHeight` of
`Bridges/ArithmeticVCDimension.lean`. The central object is the **height ultrametric**

```
heightUltra a b = if a = b then 0 else max (ratArithHeight a) (ratArithHeight b)
```

and its coordinatewise tropical aggregation `discrepancy x y = ⨆ᵢ heightUltra (xᵢ) (yᵢ)`
over a finite index type. The key conceptual discovery — recorded as a *failure analysis*
in the Lab Notebook — is that the naive "height of the difference" functional
`ratArithHeight (a − b)` is **not** ultrametric, because height is archimedean
(height of a sum is not controlled by the heights of summands; e.g.
`1/2 + 1/3 = 5/6` has height `11 > max 3 4`). The correct, ultrametric-safe functional is
the `max` of the two *endpoint* heights gated by an equality indicator. This single
choice makes the strong triangle inequality literally identical to the tropical
subadditivity law `add = max` of `tropicalization_base`.

## Results Summary (all proved, `sorry`-free, standard axioms only)

1. **`heightUltra_strong_triangle`** — `heightUltra` is a genuine ℕ-valued ultrametric
   on ℚ (with `heightUltra_self`, `heightUltra_comm`, `heightUltra_eq_zero_iff`). Being
   zero exactly on the diagonal, it is a metric, not merely a pseudometric.
2. **`discrepancy_strong_triangle`** (+ `discrepancy_self`, `discrepancy_comm`,
   `discrepancy_eq_zero_iff`) — the coordinatewise aggregate is an ultrametric on rational
   tropical presentations.
3. **`discrepancy_reindex_nonexpansive`** and **`discrepancy_reindex_equiv`** —
   every valuation-preserving morphism (reindexing `σ : κ → ι`) induces a 1-Lipschitz map,
   and bijections induce isometries: this is the functoriality of the construction.
4. **`discrepancy_prod`** — the product (over `ι ⊕ κ`) decomposes as
   `max` of the factor discrepancies: an algorithmic factorwise decomposition principle.
5. **`discrepancy_tropical_subadditive`** — the bridge identity: the strong triangle
   inequality *is* tropical subadditivity under `tropicalization_base.add`.
6. **`discrepancy_zero_iff_eq`** / `heightEquiv_iff_eq` — the height-zero quotient is
   faithful: distance zero ⟺ equality, so the reconstruction is information-lossless.

## Bold, Falsifiable Research Directions

### 1. A height-graded ultrametric refinement that detects denominators separately
The key insight is that `ratArithHeight q = |num| + den` blends two non-archimedean
signals (numerator size and denominator size) that should yield *two* commuting
ultrametrics whose `max` recovers `heightUltra`. The conjecture: define
`numUltra a b` and `denUltra a b` from `Int.natAbs (·.num)` and `(·.den)` respectively;
then `heightUltra = max numUltra denUltra` is a *join* of ultrametrics, and the
denominator component alone refines the `p`-adic valuation ultrametric on ℚ.
This is falsifiable: if `denUltra` fails the strong triangle inequality (it might, since
`den` is not sub-multiplicative under addition), the clean decomposition collapses.
**Why now?** We already have the `max`-of-ultrametrics-is-an-ultrametric machinery
(`discrepancy_strong_triangle`, `discrepancy_prod`) proved generically over `Finset.sup`,
so testing whether each factor is independently ultrametric is a direct, cheap experiment.

### 2. Northcott finiteness ⇒ local finiteness (discreteness) of the height ultrametric
The key insight is that every closed ball of radius `R` in the height ultrametric contains
only finitely many rationals, because `ratArithHeight q ≤ R` is a Northcott-type bound.
Conjecture: `{q : ℚ | heightUltra q 0 ≤ R}` is finite for every `R`, hence the metric space
`(ℚ, heightUltra)` is *uniformly discrete* and its presentation spaces are totally bounded
codebooks. This is falsifiable (a single infinite ball refutes it) and connects directly to
the VC/codebook theme of `ArithmeticVCDimension.lean`.
**Why now?** `ratArithHeight_pos` and `ratArithHeight = |num| + den` are already in the
catalog, and Mathlib's `Rat` API plus `Set.Finite` lemmas make the ball-finiteness count
tractable; this would turn the qualitative bridge into a quantitative covering-number bound.

### 3. The height ultrametric is *not* a translation-invariant norm — a sharp no-go theorem
The key insight is that the archimedean failure noted in the Lab Notebook can be promoted to
a *theorem*: there is **no** `UltraNormObj` structure on `(ℚ, +)` whose norm is monotone in
`ratArithHeight`, because `norm_add ≤ max` would force the (false) height-of-sum bound.
Conjecture: formalize and prove this impossibility, certifying that the *metric* (point-
distance) formulation of this file is genuinely necessary and not a repackaged norm.
This is falsifiable: exhibiting any such `UltraNormObj` refutes it.
**Why now?** The `UltraNormObj` interface and its `norm_add` axiom are already in the catalog,
so the no-go statement can be phrased entirely in existing vocabulary and the counterexample
`1/2 + 1/3` is already validated.

### 4. Functorial completion to a Berkovich-style space of presentation valuations
The key insight is that 1-Lipschitz functoriality (`discrepancy_reindex_nonexpansive`) makes
the height ultrametric a functor from finite index categories to ultrametric spaces, whose
colimit over all finite reindexings should be a compact "Berkovich-type" space of
height-bounded valuations. Conjecture: the inverse/direct limit of presentation spaces along
reindexings carries a canonical ultrametric, and `discrepancy_reindex_equiv` shows the limit
is independent of presentation up to isometry. Falsifiable: if the transition maps fail to be
isometric on a cofinal system, no well-defined limit metric exists.
**Why now?** We have both the nonexpansiveness and the bijection-isometry lemmas proved
generically; the categorical limit is the natural next structural target and reuses
`UltraHom.comp`/`comp_assoc` from the catalog for the functor laws.

### 5. Transfer of certified-robustness radii through the height ultrametric
The key insight is that `discrepancy_prod` (max-decomposition) is exactly the rule by which
certified perturbation radii compose across independent coordinate blocks, mirroring
`PostQuantumGapWitness` and `QuantumCertifiedRadiusData` from the catalog. Conjecture: a
height-ball of radius `R` around a presentation is a certified-robustness region whose radius
is the *minimum* coordinate height gap, and product objects inherit the minimum-of-radii rule.
This is falsifiable: a product whose certified radius exceeds the min of factor radii refutes
it.
**Why now?** The catalog already encodes certified radii as ℕ-valued gaps, and our
`discrepancy_prod` gives the matching factorwise algebra for free, so the robustness-transfer
theorem is a short, high-value composition of existing results.
