# Future Directions — Tropical overlap valuation of topological codes

Derived from the research cycle that produced
`Applications/SmoothPoincare/OverlapProfile.lean` and
`Bridges/TropicalOverlapValuation.lean` (the min-plus overlap profile, its
inf-convolution direct-sum law, and its packaging as a monotone lax-monoidal valuation
into `CategoricalTropicalUltrametric.TropicalValuationObject`).

Each conjecture below is falsifiable and stated so it can be formalized directly on top
of the existing definitions (`overlapProfile`, `overlapConv`, `maxOverlap`,
`minPlusNat`).

---

## Conjecture 1 — Overlap profiles strictly refine weight enumerators

**Statement.** There exist two binary codes `C, D ⊆ (ZMod 2)ⁿ` with *identical* tropical
weight enumerators (`twe C = twe D` and even identical full weight spectra) but
*distinct* overlap profiles (`overlapProfile C ≠ overlapProfile D` as functions on the
threshold).

**The key insight is that** weight enumerators record only the *unary* support
distribution, while the overlap profile records *bilinear* intersection geometry, so two
codes can be weight-isospectral yet overlap-distinguishable — exactly the
`overlapProfile hamming 5 = 16` phenomenon, where overlap `≥5` forces the all-ones word,
a fact `twe` cannot see.

**Why now?** The cycle already exhibits a concrete information gap on the Hamming code
(`hamming_overlapProfile_five` vs. `TropicalWeightEnumerator.hamming_twe`); constructing
an explicit weight-isospectral pair (classical examples exist among small binary codes)
turns that gap into a separation theorem, the strongest possible justification for the
new invariant.

---

## Conjecture 2 — The overlap profile is a genuine `TropHom` of bundled objects

**Statement.** Bundling each finite code `C` with its profile yields a `TropObj`, and the
direct sum `⊕c` induces a morphism in `CategoricalTropicalUltrametric.TropHom` realizing
`overlapProfile_append_conv` as a structural `map_mul'` (with `add = min` matched on both
sides), not merely an inequality.

**The key insight is that** `overlapProfile_append_conv` already proves *exact*
multiplicativity (`= overlapConv`, the tropical product), so the lax `≤` of
`overlapProfile_trop_submul` upgrades to an honest semiring homomorphism once the profile
is viewed as an element of a function-space tropical object.

**Why now?** The exact convolution law is in hand and `minPlusNat` is constructed; the
only missing step is assembling the function-space tropical object and checking the
`TropHom` axioms, all of which reduce to lemmas already proved this cycle.

---

## Conjecture 3 — Self-dual codes saturate the overlap profile at the full length

**Statement.** Every self-dual code `C ⊆ (ZMod 2)ⁿ` (the `SelfDualLength`/`GleasonLength`
regime) satisfies `maxOverlap C = n`: the maximal pairwise overlap equals the block
length, the saturated `k = ∞` end of the overlap profile.

**The key insight is that** a self-dual code contains the all-ones word
(`SelfDualLength.ip_ones` shows `𝟙` is orthogonal to all of `C`, hence in the dual = `C`),
and `overlap 𝟙 𝟙 = wt 𝟙 = n`, so the maximal overlap is forced up to the full length.

**Why now?** The cycle's exact computations already confirm the prediction on the Hamming
family: `hamming_maxOverlap = 8 = n` and, via `maxOverlap_append`,
`hamming16_maxOverlap = 16 = n`; proving the general statement needs only
`SelfDualLength.ip_ones` plus `maxOverlap`'s definition, both in hand.

---

## Conjecture 4 — Tropical convexity of the profile (discrete concavity)

**Statement.** For every code `C`, the finite-valued part of `k ↦ overlapProfile C k` is
*midpoint super-additive in cost per threshold*: whenever `overlapProfile C k` and
`overlapProfile C k''` are finite with `k'' = k + 2j`, then
`overlapProfile C k + overlapProfile C k'' ≤ 2 · overlapProfile C (k + j)` fails in
general but holds for codes closed under a transitive symmetry group.

**The key insight is that** symmetry forces the cheapest realizing pair at threshold
`k+j` to interpolate between those at `k` and `k''`, a tropical-convexity shadow of the
linear-programming bounds for codes.

**Why now?** The realization certificate `overlapProfile_le_of_pair` and witness
extractor `overlapProfile_exists` give exactly the handles needed to test convexity
computationally on `hamming` (and counterexample-hunt on asymmetric codes) before
attempting the symmetric general case.

---

## Conjecture 5 — Overlap profiles detect the Donaldson `8`-obstruction tropically

**Statement.** The min-plus integral `∑_{k≥1} (overlapProfile C k - overlapProfile C (k-1))`
(a finite telescoping over the finite thresholds) is divisible by `8` for every doubly-even
self-dual code, giving a *tropical* witness of the length-divisibility theorem
`CodeDirectSum.appendCode_length_div_eight`.

**The key insight is that** the overlap profile's increments encode the same bilinear
form data whose evenness drives `doublyEven_selfOrthogonal`, so the Gleason `8`-obstruction
should be readable off the tropicalized increments rather than the weight enumerator.

**Why now?** `overlapProfile_append_conv` shows increments add under direct sum, so an
`8`-divisible tropical functional would be *additive* across `⊕` — matching the additive
length divisibility `8 ∣ (m+n)` already proved in `CodeDirectSum`, making the conjecture a
direct tropical lift of an existing theorem.
