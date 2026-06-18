# Future Directions — Weight-Threshold Profiles & the Codes → Tropical Valuation Functor

These conjectures extend `Catalog/Bridges/CodeThresholdValuation.lean`, which builds the
functor `FinLinCodes ⥤ TropObj` via the threshold-profile valuation `tprof`, proves it is
a genuine nonarchimedean valuation (strong triangle + isosceles laws), induces an
ultrametric distance `tdist`, and assembles the prefix-inclusion family into a functor
`(ℕ, ≤) ⥤ CodeVal`. They are stated to be falsifiable and Lean-formalizable.

## Conjecture 1 — Tropical weight enumerator factors through `tprof`
The (Hamming) weight enumerator `W_C(x) = Σ_{c∈C} x^{wt c}` proved for `[8,4,4]` in
`MinimumDistance.lean` (`1 + 14x⁴ + x⁸`) has a **tropical companion** `T_C(t) = max_{c∈C,
tprof c ≤ t} wt c`, the *threshold-truncated max-weight profile*. Conjecture: `T_C` is a
piecewise-constant, monotone, **concave** tropical polynomial whose breakpoints are exactly
the distinct values of `tprof` attained on `C`, and for any self-dual code the number of
breakpoints equals `1 + (minimum distance)/4`. Testable first on `hamming` (predicted
breakpoints at `t = 7, 8`).

## Conjecture 2 — `tprof` characterises the standard-form generator order
A binary `[n,k]` code admits a generator matrix in row-echelon (standard) form iff the
multiset `{ tprof c : c ∈ C, c ≠ 0 }` contains exactly `2^k − 1` values whose distinct
representatives are `k` *consecutive-pivot* thresholds. Conjecture: `tprof`'s value set on
`C` recovers the pivot columns of the reduced row-echelon form, so the functor
`CodeVal.toTrop` is **faithful on standard-form codes** (distinct codes ⇒ distinct
threshold value-multisets). Falsifiable by exhibiting two inequivalent codes with identical
`tprof` multisets.

## Conjecture 3 — Ultrametric MacWilliams duality
For the induced ultrametric `tdist`, define the dual code `C⊥` and the *threshold ball
counting function* `N_C(r) = #{c ∈ C : tprof c ≤ r}`. Conjecture: a **MacWilliams-type
identity** relates `N_C` and `N_{C⊥}` linearly, `N_C(r) · N_{C⊥}(n−r) = |C| · 2^{?}` for a
predictable exponent, mirroring the classical weight-enumerator duality. This would make
`tprof` (not just `wt`) a self-dual invariant. Test on `hamming` (self-dual, so
`C = C⊥`): predicts `N_C(r)·N_C(8−r)` is constant in `r`.

## Conjecture 4 — Functoriality under the direct sum `C ⊕ D`
`CodeDirectSum.lean` shows `wt` is additive and self-duality is closed under coordinate
concatenation `⊕`. Conjecture: under the threshold functor,
`tprof_{C⊕D}(append a b) = max (tprof_C a) (offset + tprof_D b)` where `offset = m` (the
left block length), i.e. **`tprof` of a direct sum is the *shifted max* of the blocks** —
the tropical (max-plus) shadow of the block-diagonal Gram matrix. Hence
`CodeVal.toTrop (C ⊕ D)` is the tropical product of `CodeVal.toTrop C` and a shifted
`CodeVal.toTrop D`, upgrading the functor to a **lax monoidal** functor
`(FinLinCodes, ⊕) → (TropObj, ⊗_max)`.

## Conjecture 5 — The multiplicative obstruction is exactly char ≠ "order valuation"
The Lab Notes record that the catalog's `UltraNormObj` requires a *multiplicative* norm,
which `tprof` (additive: `v(xy)=v x + v y` for polynomial mult) cannot meet. Conjecture:
viewing `Fin n → ZMod 2` as `F₂[t]/(tⁿ)`, the **order valuation** `ord(x)` (lowest active
coordinate) satisfies `ord(x·y) = min(ord x + ord y, n)` exactly, and the transform
`val(x) = n − ord(x)` is the *unique* ℕ-valued, max-ultrametric refinement of `tprof` that
becomes multiplicative after the exponential reparametrisation `B^{val}`. Formalizing this
would land codes in the catalog's full `UltraNormObj`/`valuationReconstruct` pipeline,
closing the gap noted in the failure analysis. Falsifiable by computing `ord` on a product
where truncation makes the identity fail for `< n`.
