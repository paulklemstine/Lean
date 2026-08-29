# Computational Evidence — exp 561 (batch smoothness testing)

All numbers below were produced with `#eval` inside the Lean project itself
(Mathlib arithmetic, exact integers / rationals — no floating point, no external
scripts).  They motivated the theorems in
`Catalog/Applications/BatchSmoothnessCorrectness.lean`,
`Catalog/Applications/BatchSmoothnessCost.lean` and
`Catalog/Applications/BatchSmoothnessYield.lean`.

## 1. Exact-match audit (extends the 500/500 sample of exp 561)

Batch criterion `n ∣ P^t` with `P = primorialUpTo 100` (product of the 25 primes
`≤ 100`), against per-item trial division `∀ p ∈ n.primeFactors, p ≤ 100`.

| pool | exponent `t` | batch-accepted | trial-accepted | Finsets equal? |
|---|---|---|---|---|
| `1 … 500`  | 9  | 384  | 384  | yes |
| `1 … 2000` | 11 | 1138 | 1138 | yes |

```
#eval ((Finset.Icc 1 2000).filter (fun n => n ∣ (primorialUpTo 100)^11)).card   -- 1138
#eval ((Finset.Icc 1 2000).filter (fun n => n ∣ (primorialUpTo 100)^11))
        = ((Finset.Icc 1 2000).filter (fun n => ∀ p ∈ n.primeFactors, p ≤ 100)) -- true
```

The sampling experiment was replaced by a proof:
`BatchSmoothness.batch_filter_eq_trial_filter` shows the two filtered sets are
equal for *every* pool of candidates below `2 ^ t`, and `batch_audit_500`
instantiates it at the audited pool.  A counterexample hunt is therefore
vacuous; instead we hunted for the *boundary*, and found it: dropping the size
bound breaks completeness already at `n = 4`
(`criterion_fails_without_size_bound`), and the exponent `t` cannot be lowered
(`exponent_sharp`).

Sanity data for the modulus: `Nat.log2 (primorialUpTo 100) = 120`, i.e. `P` is a
121-bit number — the root of the factor-base product tree.

## 2. Smooth-density collapse ("yield far below quota")

Counting 100-smooth integers in windows of increasing height:

| window | width | 100-smooth | density |
|---|---|---|---|
| `1 … 2000` | 2 000 | 1138 | 5.7 · 10⁻¹ |
| `10⁶ … 10⁶ + 10⁴` | 10 001 | 417 | 4.2 · 10⁻² |
| `2⁴⁰ … 2⁴⁰ + 10⁴` | 10 001 | 1 | 1.0 · 10⁻⁴ |

The quadratic sieve at `B = 100` needs `π(100) + 1 = 26` relations
(`BatchYield.quota_at_B100` proves `π(100) = 25`;
`BatchYield.exists_square_subproduct` proves 26 relations always suffice).  At
the measured bit-length-40 density of ≈ 10⁻⁴ that requires on the order of
`26 / 10⁻⁴ ≈ 2.6 · 10⁵` candidates, three orders of magnitude beyond the largest
pool tested (`k = 512`).  This is a *yield* deficit, not an algorithmic failure —
consistent with `qs_splits_total = 0` in exp 561.

## 3. Product-tree cost tables

`treeFlatOps L` (internal nodes) and `treeWordCost 8 L` (schoolbook word
operations, 8-word leaves):

| `L` | pool `2^L` | flat ops | word ops |
|---|---|---|---|
| 0 | 1   | 0   | 0        |
| 3 | 8   | 7   | 1 792    |
| 6 | 64  | 63  | 129 024  |
| 9 | 512 | 511 | 8 372 224 |

Flat cost is linear in the pool, word cost multiplies by ≈ 4 whenever the pool
doubles — the measured sign reversal.  Both patterns are proved:
`treeFlatOps_succ_eq` (`= 2^L − 1`) and `treeWordCost_closed`
(`2·cost + w²2^L = w²4^L`); `word_batch_reversal` turns the second into an
explicit pool threshold beyond which the tree alone outcosts all of solo trial
division.

## 4. Flat-model amortization table (illustrative constants)

With `s = 25` solo ops per candidate, batch setup `A = 25` and per-candidate
batch cost `c = 11`:

| `k` | batch `A + ck` | solo `sk` | relative saving |
|---|---|---|---|
| 1   | 36   | 25    | −11/25 = −0.44 |
| 8   | 113  | 200   | 87/200 = 0.435 |
| 64  | 729  | 1600  | 871/1600 = 0.544 |
| 512 | 5657 | 12800 | 7143/12800 = 0.558 |

The saving increases monotonically towards the ceiling `(s − c)/s = 0.56`,
exactly as `flatSaving_strictMono` and `flatSaving_tendsto` predict.  Note that
with these constants batch *loses* at `k = 1`; exp 561 reports a win at every
measured pool, which in the model is the condition `A < s − c`
(`flat_batch_lt_solo`).  So the measurement pins the setup cost down, rather
than the other way round.

## 5. Consistency of the headline numbers

Testing share `f = 0.1156`, realized overall gain `d = 0.104`.  Exact rational
arithmetic gives a surviving testing cost of
`1 − d/f = 1 − 1040/1156 = 29/289 ≈ 0.1003` of the solo testing phase
(`BatchCost.exp561_phase_residual`), i.e. a ≈ 9.97× speedup of the testing phase
alone.  Any claim above `f` would be impossible
(`overall_saving_le_testing_share`), and even a free testing phase caps the
end-to-end speedup at `1/(1 − f) ≈ 1.131` (`speedup_factor_le`).
