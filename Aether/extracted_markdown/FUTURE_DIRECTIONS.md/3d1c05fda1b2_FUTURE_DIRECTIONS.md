# Future Directions: Tropical weight enumerator profiles, cycle 2

This cycle added two `sorry`-free files on top of `TropicalWeightEnumerator.lean`:

* **`TropicalHullRecovery.lean`** — realizes *Conjecture 1* (tropical hull recovery).
  The headline `realizedSlope_iff` proves that a weight `w` of a nonempty binary code is
  realized as a *strict* minimizing slope of the profile `t ↦ twe C t` for some real `t`
  **iff** `w` is a vertex of the (degenerate, height-`1`) lower convex hull of the weight
  spectrum, i.e. `w = minWt C` or `w = maxWt C`. Instantiated on the extended Hamming
  `[8,4,4]` code: `hamming_minWt = 0`, `hamming_maxWt = 8`, weights `0` and `8` are
  realized (`hamming_zero_realized`, `hamming_eight_realized`), and the minimum distance
  `4` is provably **not** realized (`hamming_four_not_realized`) — the exact information
  loss in `hamming_twe`.

* **`TropicalProfileDuality.lean`** — realizes the *general* form of *Conjecture 4*.
  `twePlus_add_twe_eq` proves that for **any** self-complementary code (closed under
  adding `ones n`), `twePlus C t + twe C t = n·t` for all real `t`, dropping the
  redundant `ones ∈ C` hypothesis from the previous cycle's conjecture shape. The
  hamming-specific identity is recovered as `hamming_twePlus_add_twe'`.

The conjectures below are derived from these findings and from what resisted proof.

---

## Conjecture A (Hull recovery with multiplicity — the polygonal profile)

**Claim.** Track multiplicities: form the multiset `{(wt c, 1) : c ∈ C}` and the
piecewise-linear profile `t ↦ twe C t`. Then the *breakpoints* (slope-change abscissae)
of the profile are exactly the abscissae of the lower-convex-hull vertices of the point
set `{(w, m_w)}` where `m_w` is the log-multiplicity, and the *number of distinct linear
pieces* equals the number of hull vertices. For a self-complementary code this vertex set
is symmetric about `n/2`.

**The key insight is** that `realizedSlope_iff` already pins the two *extreme* hull
vertices (`minWt`, `maxWt`); the missing content is purely the *interior* vertices, which
appear only once multiplicities (heights `m_w`) lift the degenerate height-`1` hull into a
genuinely strictly-convex polygon.

**Why now?** `TropicalHullRecovery.lean` supplies the endpoint case `sorry`-free and the
exact `realizedSlope` predicate; the interior-vertex generalization is a clean induction
on the number of distinct weights, with the extremes as base case.

**Suggested Lean shape.**
```
theorem twe_breakpoints_eq_hull_vertices (C) (hC) :
    breakpoints (twe C hC) = lowerHullVertices {(wt c, logMult C (wt c)) | c ∈ C}
```

---

## Conjecture B (Tropical Mallows–Sloane distance bound — the short-length cases)

**Claim.** Every binary doubly-even self-dual code of length `n ≤ 22` has minimum
distance `≤ 4`, and length `n` with `24 ≤ n ≤ 46` has `minDist ≤ 8`; in general
`minDist C ≤ 4·⌊n/24⌋ + 4`. The tropical-`min` law `minDist_append` shows the bound is a
**global, non-additive** obstruction: stacking codes keeps `minDist = min`, never sums it.

**The key insight is** that the bound is the *distance-side* shadow of Gleason length
divisibility (`doublyEven_selfDual_length_div_eight`): the same `(1+I)`-tower that forces
`8 ∣ n` constrains the weight enumerator to a Gleason-invariant ring, whose lowest-degree
generator caps the minimum distance.

**Why now?** `GleasonLength.lean` already formalizes the full Gauss-sum/MacWilliams
machinery `(|C| : ℂ) = (1+I)ⁿ` and `card_eq_onePlusI_pow`; the short-length cases
(`⌊n/24⌋ = 0`, i.e. `n ∈ {8, 16}`) reduce to a finite invariant-theory computation that
`native_decide` can finish on explicit Gleason generators.

**First test.** `n = 8` (`hamming`, bound `4`, tight via `hamming_minDist = 4`) and
`n = 16` (`hamming16`, bound `4`, tight via `hamming16_minDist = 4`).

---

## Conjecture C (Tropical indecomposability via slope-splitting)

**Claim.** `twe_append` is *not* invertible in general, but its converse holds on slopes:
if for **every** real `t` the value `twe C t` fails to split as `twe C₁ t + twe C₂ t` for
all length-decompositions `n = m + k` with nonempty `C₁, C₂`, then `C` is indecomposable
(not a coordinate direct sum). Concretely, indecomposability is detected by a single slope
`t₀` where `minWt C ≠ minWt C₁ + minWt C₂` for every candidate split.

**The key insight is** that `minWt` and `maxWt` (now first-class via
`TropicalHullRecovery.lean`) are *additive* under direct sum exactly when the code splits,
so a hull-vertex mismatch at the extreme slopes `t = ±1` certifies indecomposability
without enumerating all decompositions.

**Why now?** With `minWt`/`maxWt` and `realizedSlope_iff` in hand, the extreme-slope test
is a finite check; the cyclic `[7,4]` Hamming code is the natural first witness.

**Suggested Lean shape.**
```
theorem indecomposable_of_minWt_not_additive (C) (hC) :
    (∀ m k (h : m + k = n) C₁ C₂ hC₁ hC₂,
        minWt C hC ≠ minWt C₁ hC₁ + minWt C₂ hC₂) → Indecomposable C
```

---

## Conjecture D (Self-complementary ⇔ symmetric profile)

**Claim.** A code `C` is self-complementary (closed under adding `ones n`) **iff** its
tropical profile pair is symmetric: `twePlus C t + twe C t = n·t` for all `t`. The forward
direction is `twePlus_add_twe_eq`; the **converse** is the new content — profile symmetry
forces the weight spectrum to be symmetric about `n/2`, which for *linear* codes is
equivalent to containing `ones n` and hence to complement closure.

**The key insight is** that `twePlus_add_twe_eq` reduces the geometric statement
"spectrum symmetric about `n/2`" to the single functional identity `twePlus + twe = n·t`,
turning a counting condition into a tropical one; the converse is then a spectrum-symmetry
extraction at the two extreme slopes `±1`.

**Why now?** The forward implication is proved `sorry`-free this cycle for arbitrary
length; the converse needs only `minWt`/`maxWt` symmetry plus linearity
(`add_mem_selfDual`), both already in the catalog.

---

## Conjecture E (Tropical–ultrametric bridge: reconstruction = Hamming)

**Claim.** The map `C ↦ (t ↦ twe C t)` is a monoidal functor from the direct-sum monoid
of binary codes to the min-plus valuation object of
`Bridges/CategoricalTropicalUltrametric` (sending `⊕c` to `+`, which is exactly
`twe_append`), and the ultrametric reconstructed from `twe` coincides with the
Hamming-distance ultrametric on codewords.

**The key insight is** that `twe_append` is literally the monoid-hom condition
`twe (C ⊕c D) = twe C + twe D`, so the functoriality is *already proved*; only the
valuation-reconstruction equality remains, and it is pinned by `wt_append` being the
tropical valuation of concatenation.

**Why now?** `twe_append` (previous cycle) and the additivity infrastructure
(`wt_append`, `minDist_append`) give the monoidal structure for free; the bridge file
`CategoricalTropicalUltrametric.lean` already exists, so only the reconstruction lemma is
new work.
