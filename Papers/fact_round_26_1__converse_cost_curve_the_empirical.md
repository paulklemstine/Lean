# Computational evidence — CONVERSE-COST-CURVE (witness family on one plane)

All numbers below were produced inside Lean (`#eval` on the same definitions
that the theorems are stated about), so the data and the formal statements
cannot drift apart.

## 1. The witness table

`N = p·q`, `M₁(N) = ∑_{x<N} gcd(x,N)` (W1), `firstHit` = least `x ≥ 1` with
`gcd(x,N) > 1` (W2), `hits` = `#{x < N : gcd(x,N) > 1}`, `idem` =
`#{x < N : x² ≡ x (mod N)}` (W4, **including** `x = 0`).

| p | q | N | M₁(N) | 4N−2(p+q)+1 | firstHit | hits | p+q−1 | idem |
|---|---|---|---|---|---|---|---|---|
| 3 | 5 | 15 | 45 | 45 | 3 | 7 | 7 | 4 |
| 3 | 7 | 21 | 65 | 65 | 3 | 9 | 9 | 4 |
| 5 | 7 | 35 | 117 | 117 | 5 | 11 | 11 | 4 |
| 5 | 11 | 55 | 189 | 189 | 5 | 15 | 15 | 4 |
| 7 | 11 | 77 | 273 | 273 | 7 | 17 | 17 | 4 |
| 11 | 13 | 143 | 525 | 525 | 11 | 23 | 23 | 4 |
| 13 | 17 | 221 | 825 | 825 | 13 | 29 | 29 | 4 |
| 17 | 19 | 323 | 1221 | 1221 | 17 | 35 | 35 | 4 |
| 23 | 29 | 667 | 2565 | 2565 | 23 | 51 | 51 | 4 |
| 31 | 37 | 1147 | 4453 | 4453 | 31 | 67 | 67 | 4 |

Three exact patterns are visible and each became a theorem:

* `M₁(N) = 4N − 2(p+q) + 1` → `ConverseCost.pillai_semiprime`;
* `firstHit = min(p,q)` and `hits = p+q−1` →
  `ConverseCost.firstHit_isLeast`, `ConverseCost.hits_card`;
* `idem = 4` constantly → `ConverseCost.idempotent_card`, and therefore
  `ConverseCost.idempotent_count_is_constant`: the W4 *counter* carries no
  information at all about the factorisation.

## 2. OEIS

`M₁` is Pillai's arithmetical function, OEIS **A018804**.  The computed initial
segment (`N = 1 … 15`) is

```
1, 3, 5, 8, 9, 15, 13, 20, 21, 27, 21, 40, 25, 39, 45
```

which matches A018804.  The theorem proved here is the restriction of
`A018804` to semiprimes, in the affine form `M₁ = 4N − 2s + 1`.

## 3. Counterexample hunt (boundary of the family)

The "count = 4" law is specific to squarefree semiprimes; the hunt for its
boundary produced:

| N | structure | idem(N) |
|---|---|---|
| 49 | `p²` | 2 |
| 27 | `p³` | 2 |
| 105 | `p·q·r` | 8 |

So `4 = 2²` is the CRT count `2^{ω(N)}` with `ω = 2`, and `x = 0` must be
counted: dropping it gives `3`, which is what broke the original experimental
assertion.  No counterexample to the semiprime statements was found; all of
them are now theorems — and the pattern in this very table became the general
theorem `ConverseCost.idempotent_card_eq_two_pow_omega`
(`#idempotents = 2^{ω(N)}` for every `N > 0`), proved in cycle 4.

## 4. Cost side

`firstHit = min(p,q)` in every row above (`10/10`, matching the reported
`60/60`).  For the balanced rows the ratio `min(p,q)/√N` sits at
`0.77 … 0.92`, consistent with the proved two-sided bound
`N ≤ 2·min(p,q)²` (balanced case, `ConverseCost.balanced_scan_cost`) and
`min(p,q)² ≤ N` (`ConverseCost.scan_cost_le_sqrt`).

The blindness data for the naive scan is machine-checked inside Lean as a lab
note: `transcript naiveScan 143 10 = List.replicate 10 1` — ten probes of
`N = 143` return no information whatsoever, which is the finite shadow of
`ConverseCost.no_oracle_algorithm`.

## 5. Two further checks turned into theorems

* `∑ gcd(x,35)² = 1595`, matching the class-wide closed form
  `f(N) + (q−1)f(p) + (p−1)f(q) + (p−1)(q−1)f(1)` with `f = (·)²`
  (`ConverseCost.gcdStat_semiprime`).
* `M₁(N) + 1 = 2φ(N) + 2N` on every row of the table above; e.g. for `N = 143`,
  `525 + 1 = 2·120 + 286` (`ConverseCost.pillai_eq_two_totient`).

## 6. Square roots of unity (cycle 5)

Counts of `#{x < N : x² ≡ 1 mod N}`, each one machine-checked by `decide` as a
lab note in `Catalog/Combinatorics/ConverseCostSquareRootLadder.lean`:

| `N` | shape | `ω(N)` | `#{x² ≡ 1}` |
|---|---|---|---|
| 9 | `p²` | 1 | 2 |
| 15 | `p·q` | 2 | 4 |
| 35 | `p·q` | 2 | 4 |
| 45 | `p²·q` | 2 | 4 |
| 105 | `p·q·r` | 3 | 8 |
| 8 | `2³` | 1 | **4** |

The odd rows follow the law `2^{ω(N)}` exactly — and only `ω` is seen, never
the exponents (`9` versus `45`) and never the primes themselves (`15` versus
`35`).  The last row is the boundary: at `N = 8` the count is `4` while
`ω(8) = 1`, so the ladder genuinely needs the oddness hypothesis.  Both facts
are now theorems: `ConverseCost.sqrtOne_card_eq_two_pow_omega` for odd `N`, and
the `ZMod 8` lab note as its counterexample-to-the-even-case.  For `N = 35` the
explicit root set is `{1, 6, 29, 34}`, and the nontrivial root `6` reveals the
factor `5` through `gcd(6 − 1, 35)`, matching
`ConverseCost.nontrivial_sqrtOne_reveals_factor`.
