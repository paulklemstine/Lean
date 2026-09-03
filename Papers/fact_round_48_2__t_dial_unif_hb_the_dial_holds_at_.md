# Computational evidence — OR-dial inflation invariance and multiplier washout

All numbers below were produced with `Float` arithmetic inside Lean (`#eval`, exploratory
scratch code, **not** kernel-verified).  They were used to check the statements *before*
formalising them; the statements themselves are proved without any numerical input in
`Catalog/Bridges/ORDialWashoutInvariance.lean`, `ORDialWashoutParity.lean`,
`ORDialCharacterWashout.lean` and `ORDialMultiPrimeWashout.lean`.

The dial is `Φ(s) = H(μ²) − avg_c H(f(c))` in nats, with `f = s ⋆ s`, `μ = avg s`
(`ORDial.orInfo`).  The cap is `orCap = (3/2)log 2 − (3/4)log 3 = 0.2157615…` nats
(`0.31128…` bits); `orCap > 0` is proved formally as `ORDial.orCap_pos`.

## 1. Semiprime dial on small cyclic class groups

| class group | profile | Φ (nats) |
|---|---|---|
| ℤ/6 | indicator of `{0,2,4}` (index-two kernel) | 0.215762 |
| ℤ/6 | indicator of `{1,3,5}` (its coset) | 0.215762 |
| ℤ/6 | indicator of `{0,3}` (index three) | 0.136661 |
| ℤ/6 | constant `1/2` | −0.000000 |
| ℤ/12 | pull-back of the ℤ/6 character (even classes) | 0.215762 |
| ℤ/5 | indicator of `{0}` | 0.067864 |
| ℤ/5 | indicator of `{0,1}` | 0.104907 |
| — | `orCap` closed form | 0.215762 |

Reading: the index-three kernel of ℤ/6 gives `0.136661`, strictly between `0` and the cap,
which is the `d = 3` instance of `orInfo_subgroupProfile_pos` (strict positivity of the
residue dial at every index `d ≥ 2`).  The cap itself is attained exactly at index-two
kernels and their cosets; the value is
**unchanged** when the class group is inflated from ℤ/6 to ℤ/12 (formalised as
`orInfo_comp_surjective` / `orInfo_prod_fst`); on the odd-order group ℤ/5 every probe is
strictly below the cap (formalised as `no_max_of_odd_card`, and, for randomised samplers,
`washout_of_odd_index`).

## 2. Multiplier randomisation on ℤ/12 (character = even classes, `K` of index two)

| multiplier group `H` | `[G : H]` | Φ(mix_H s) | mean rate |
|---|---|---|---|
| `{0}` (fixed `k = 1`) | 12 | 0.215762 | 0.5 |
| `{0,4,8}` (order 3) | 4 | 0.215762 | 0.5 |
| `{0,6}` (order 2) | 6 | 0.215762 | 0.5 |
| `{0,3,6,9}` (order 4) | 3 | −0.000000 | 0.5 |
| all of ℤ/12 | 1 | −0.000000 | 0.5 |

Reading: the channel survives exactly for the multiplier groups contained in the
index-two subgroup — equivalently (over a finite abelian class group) exactly when
`[G : H]` is even.  This is `washout_dichotomy` / `washout_iff_even_index`.  The last
column is the count statistic: it is *identical* in every row, which is the formal content
of `count_blind_dial_separates` and `quadChar_channel_collapse` ("T beats count": the mean
rate cannot separate rows that the dial separates by the full cap).

## 3. Multi-prime decay of the index-two kernel value

`H(2^{-k}) − ½ H(2^{-(k-1)})` for `k = 2,3,4,5,6`:

```
[0.215762, 0.095603, 0.045407, 0.022165, 0.010954]
```

Reading: equal to `orCap` at `k = 2`, strictly decreasing afterwards, but never zero.
The upper bound (`< orCap` for `k ≥ 3`) is the catalogue result
`multiInfo_index_two_lt_orCap`; the new lower bound (`> 0` for all `k ≥ 2`) is
`multiInfo_index_two_pos`, proved from the sharpened tangent sandwich
`-x log x + x(1-x) ≤ H(x) ≤ -x log x + x`.  Ratios of successive entries approach `1/2`,
consistent with the leading term `2^{-(k+1)} log 2` extracted in the proof.

## 4. Counterexample hunt

* *Can an odd-index multiplier group keep the cap?*  For the multiplier groups of ℤ/12
  listed above the answer is no: the two odd-index rows both read `0`.  Formal reason: an
  index-two subgroup containing `H` forces `2 ∣ [G : H]`
  (`even_index_of_le_index_two`).
* *Is inflation invariance an artefact of the product structure?*  The two index-two and
  index-three profiles of ℤ/6 give `0.215762` and `0.136661`; pulled back along the
  reduction ℤ/12 → ℤ/6 they again give `0.215762` and `0.136661`, and pulled back along
  the projection ℤ/6 × ℤ/2 → ℤ/6 (first coordinate) once more `0.215762` and `0.136661`.
  The formal statement is for an arbitrary surjective homomorphism, so no splitting is
  used.
* *Does washout also kill the count statistic?*  No — the mean rate is exactly preserved
  (`avg_mix`), which is why a count-based detector sees nothing at all where the dial sees
  the whole cap.

No counterexample to any formalised statement was found.

## 5. Second cycle: the degradation law `dialAt` and the budget threshold

Exploratory floating-point evaluation (not kernel-verified) of

`dialAt(u) = H(1/4) − ½(H((1+u)/4) + H((1−u)/4))`

at the squared contrast `u = t²` of the profile `charProfile K t = (1 + t·χ)/2`:

| `t`  | 0 | 0.1 | 0.25 | 0.5 | 0.75 | 0.9 | 1 |
|------|---|-----|------|-----|------|-----|---|
| `dialAt(t²)` | 0.000000 | 0.000017 | 0.000651 | 0.010503 | 0.055218 | 0.122478 | 0.215762 |

The last entry agrees with `orCap = 0.215762` and the first with `0`, matching the formal
`orInfo_charProfile_endpoints`; the row is strictly increasing, matching
`dialAt_strictMonoOn`.  The very flat start (`t = 0.1` reads `1.7·10⁻⁵`) is the reason a
partially randomised sampler looks indistinguishable from a fully randomised one in small
samples even though the dial is formally nonzero.

*Counterexample hunt for the naive Fourier bound.*  A tempting quantitative form of the
degradation law is `orInfo s ≤ dialAt(max_χ c_χ(s)²)` with contrasts
`c_χ(s) = 2·avg(s·χ)`.  This is **false**: on `G = (ℤ/2)²` the point-mass profile
`s = 1_{{0}}` has all three nontrivial contrasts equal to `1/2`, so the right-hand side is
`dialAt(1/4) = 0.010503`, while the profile's own dial is `0.093208`.  The sum-of-squares
version `orInfo s ≤ dialAt(min(1, √(Σ_{χ≠1} c_χ²)))` survives this instance
(`√(3/4) = 0.866`, `dialAt(0.866) = 0.143542 > 0.093208`) and is the form carried forward
as a conjecture in `FUTURE_DIRECTIONS.md`.  These two numbers are exploratory Float
computations, not formal results.

*Budget threshold.*  For the class groups used above, `twoPartCard` is `4` for `ℤ/12`,
`2` for `ℤ/6`, `4` for `ℤ/6 × ℤ/2` and `1` for `ℤ/5`; the formal
`budgeted_dial_dichotomy` then says the dial survives every multiplier group of order
`< 4`, `< 2`, `< 4` and `< 1` respectively — the last being the statement that the odd
class group `ℤ/5` carries no maximal channel at all, consistent with the `0` entries
recorded for `ℤ/5` in §2.
