# Future Directions — Cumulative weight thresholds & convolution of binary linear codes

Derived from this research cycle, which added two `sorry`-free Lean files to
`Catalog/Applications/SmoothPoincare/`:

- `CumulativeWeightConvolution.lean` — the monotone threshold count
  `wcount C t = #{c ∈ C : wt c ≤ t}`, its **supermultiplicative convolution bound**
  `wcount C s · wcount D r ≤ wcount (C ⊕ D) (s+r)` (`wcount_append_ge`), the **exact
  sliding-threshold convolution** `wcount_append`, and the strict Hamming gap
  `225 < 227` (`hamming16_wcount_strict`).
- `WeightDistributionConvolution.lean` — the weight distribution
  `wexact C t = #{c ∈ C : wt c = t}`, the **exact Cauchy convolution**
  `wexact (C ⊕ D) t = ∑_{s≤t} wexact C s · wexact D (t−s)` (`wexact_append`),
  the CDF/PMF link `wcount = ∑ wexact` (`wcount_eq_sum_wexact`), and the `E8⊕E8`-shadow
  reconstruction `1·1 + 14·14 + 1·1 = 198` (`hamming16_wexact_convolution`).

This established the dictionary
**product (cardinality) ⊃ Cauchy convolution (`wexact`) ⊃ prefix-convolution-inequality
(`wcount`) ⊃ tropical-min hull (`twe`)**. The conjectures below push each layer.

---

## Conjecture 1 — Log-concavity of the threshold count is *not* universal, but holds for direct-sum powers
**Statement.** For an arbitrary binary code `C`, the cumulative sequence `t ↦ wcount C t`
need not be log-concave; but for the `k`-fold direct sum `C^{⊕k}` the *normalized*
distribution `wexact (C^{⊕k})` becomes asymptotically log-concave (a discrete CLT for the
weight under repeated concatenation).

**The key insight is** that `wexact` is a Cauchy convolution monoid (`wexact_append`), so
`wexact (C^{⊕k})` is the `k`-fold self-convolution of a fixed finite nonnegative sequence —
exactly the setting where Newton/CLT-type log-concavity emerges, even when one copy fails it
(the Hamming spectrum `1,0,0,0,14,0,0,0,1` is itself *not* log-concave, giving a clean
falsification target for the "universal" version).

**Why now?** `wexact_append` and `sum_wexact_eq_card` already give the convolution algebra
and its normalization in Lean; the only missing ingredient is a finite-support
self-convolution log-concavity lemma, which is within reach of the current `Finset.sum`
machinery.

---

## Conjecture 2 — The strict gap in `wcount_append_ge` exactly counts cross-strata
**Statement.** `wcount (C ⊕ D) (s+r) − wcount C s · wcount D r =
∑_{(a,b): wt a ≤ s+r, wt b ≤ s+r, ¬(wt a ≤ s ∧ wt b ≤ r)} 1`, i.e. the deficit of the
tropical bound is precisely the number of concatenations living *outside* the rectangle
`{≤s}×{≤r}` but inside the simplex `{wt a + wt b ≤ s+r}`.

**The key insight is** that the supermultiplicative bound `wcount_append_ge` came from a
rectangle-into-simplex injection; its failure to be onto is governed term-by-term by the
exact convolution `wcount_append`, so the gap is a sum of honest cross-stratum counts (on
Hamming: the `(8,0)` and `(0,8)` blocks giving `227−225 = 2`).

**Why now?** Both the bound and the exact convolution are already proved `sorry`-free in the
same namespace; subtracting them is a finite `Finset` identity, and the Hamming instance
`227 − 225 = 2` is an immediate sanity check (`hamming16_wcount_strict`).

---

## Conjecture 3 — A MacWilliams-style threshold transform is convolution-diagonalizing
**Statement.** There is an explicit linear "threshold transform" `T` (a triangular
prefix-sum operator) under which `T(wexact C)` of a self-dual code is a *fixed point up to a
binomial weighting*, and `T` turns the Cauchy convolution `wexact_append` into pointwise
multiplication, mirroring how the Fourier/MacWilliams transform diagonalizes the weight
enumerator product.

**The key insight is** that `wcount_eq_sum_wexact` already exhibits the prefix-sum operator
linking PMF to CDF; promoting it to a full triangular transform should send the convolution
monoid `(wexact, ∗)` to a pointwise-product algebra, the discrete shadow of
`W_{C⊕D} = W_C·W_D`.

**Why now?** The convolution identity is formalized; the prefix-sum half of the transform is
`wcount_eq_sum_wexact`. What remains is to characterize the transform's action on self-dual
spectra, where the catalog already supplies `hamming_selfDual` and `appendCode_selfDual`.

---

## Conjecture 4 — Threshold count separates codes that the tropical hull `twe` cannot
**Statement.** There exist two binary codes `C`, `C′` of the same length with identical
tropical enumerators `twe C = twe C′` (same weight-hull) yet different cumulative counts
`wcount C ≠ wcount C′`; consequently `wcount` is a *strictly finer* direct-sum invariant
than `twe`.

**The key insight is** that `twe` only sees the convex hull of the weight spectrum (proved
in `TropicalWeightEnumerator.hamming_twe`, where the minimum distance `4` is invisible),
whereas `wcount` records every interior stratum (`hamming_wcount_four = 15` exposes exactly
that erased weight-`4` jump). Two codes sharing hull endpoints but differing in an interior
stratum realize the separation.

**Why now?** The erasure phenomenon is already a theorem (`hamming_twe`), and the interior
visibility is already a theorem (`hamming_wcount_four`); the conjecture only asks to exhibit
an explicit pair, a finite `native_decide`-checkable search over short codes.

---

## Conjecture 5 — Threshold supermultiplicativity yields a Singleton-type bound
**Statement.** For any nonempty code `C ⊆ (ZMod 2)^n` with minimum distance `d`,
`wcount C (d−1) = 1` and the supermultiplicative law forces, for the `k`-fold power,
`wcount (C^{⊕k}) (k(d−1)) = 1`, giving a *stable* lower estimate on the minimum distance of
iterated direct sums and a clean tropical proof that `minDist(C^{⊕k}) = d`.

**The key insight is** that `wcount C (d−1) = 1` (only the zero codeword) combined with
`wcount_append_ge` propagates the "only zero below threshold" property multiplicatively, so
the minimum distance is *preserved* (not improved) under direct sum — recovering
`TropicalWeightEnumerator.minDist_append`'s `min` law from the threshold side.

**Why now?** `wcount_append_ge`, `wcount_zero`, and the catalog's `minDist`/`minDist_append`
are all already in place; the bridge is a short induction on `k` over the already-formalized
supermultiplicative inequality.
