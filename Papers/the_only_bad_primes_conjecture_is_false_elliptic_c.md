# Computational evidence: denominators of `x(2ⁿ P)` on Mordell curves

All data below were produced by `scripts/survey.py` (exact rational arithmetic
with `fractions.Fraction`, Miller–Rabin + Pollard rho for factorisation).  The
qualitative facts they exhibit are all proved in Lean in
`Catalog/Cryptography/MordellDenominators/`; the tables are exploratory only
and are *not* themselves formal verifications.

## 1. The claimed counterexample, recomputed

`E₅₅ : y² = x³ + 55`, `P = (9, 28)` (indeed `28² = 784 = 9³ + 55`).

```
x(2P) = (9⁴ − 8·55·9) / (4·(9³+55)) = 2601/3136,   3136 = 2⁶ · 7²
```

`Δ = −432·55² = −1 306 800 = −2⁴·3³·5²·11²`, so the bad primes are
`{2, 3, 5, 11}`.  The prime `7` divides the denominator and is a prime of
**good** reduction.  Note also that *neither* `5` nor `11` divides `3136`: the
denominator does not expose the factorisation `55 = 5 · 11`.

Formalised in `Counterexample.lean`
(`N55.den_dblX`, `N55.seven_good`, `N55.not_onlyBadPrimes`,
`N55.five_not_dvd_den`, `N55.eleven_not_dvd_den`).

## 2. Small-case survey over 11 semiprimes

For each semiprime `N = p·q` we take the first integral point found with
`|x| ≤ 3000` and iterate the duplication map.  `only-bad?` records whether all
primes of that denominator lie in `{2, 3, p, q}`.  For `k = 3` only prime
divisors below 1000 were extracted (the denominators have ~70 digits).

```
   N=pq             P  k          den(x(2^k P))  primes                only-bad?
     55       (9, 28)  1                   3136  [2, 7]                False
     55       (9, 28)  2      21498536380459264  [2, 7, 827, 1583]     False
     55       (9, 28)  3  4322918042512788991…   [2, 7, 827]  (partial)
     15        (1, 4)  1                     64  [2]                   True
     15        (1, 4)  2              575232256  [2, 1499]             False
     15        (1, 4)  3  1477247788855707311…   [2, 263]     (partial)
     35        (1, 6)  1                     16  [2]                   True
     35        (1, 6)  2                7268416  [2, 337]              False
     35        (1, 6)  3  1801814018870813248…   [2, 23, 337] (partial)
     33       (-2, 5)  1                     25  [5]                   False
     33       (-2, 5)  2               75777025  [5, 1741]             False
     65       (-4, 1)  1                      1  []                    True
     65       (-4, 1)  2              199176769  [11, 1283]            False
     91       (-3, 8)  1                    256  [2]                   True
     91       (-3, 8)  2         13462206751744  [2, 114659]           False
    143       (1, 12)  1                     64  [2]                   True
    143       (1, 12)  2             9072181504  [2, 5953]             False
     21, 77, 39, 14 : no integral point with |x| ≤ 3000
```

Summary over the 7 curves for which a small integral point exists, using the
denominators of `x(2P)` and `x(4P)`:

| statistic | value |
|---|---|
| `N` for which `p` occurs in some denominator | 0/7 |
| `N` for which `q` occurs in some denominator | 0/7 |
| `N` for which "only `{2,3,p,q}`" holds up to `k = 2` | 0/7 |

So in this sample the conjecture fails for **every** curve by the second
doubling, and — the sharper point — the primes `p, q` one would want to read
off never appeared at all.  The denominators expose *other* primes
(`7, 827, 1583, 1499, 337, 1741, 1283, 114659, 5953, …`), all of good
reduction.

*(Caveat: `N = 33` shows `5` in the denominator, and `N = 65 = 5·13` shows
`11`; these are good primes, not factors of `N`.)*

## 3. Valuations along the orbit (rigidity)

For `N = 55`, `P = (9, 28)`:

```
 k   v₂(den x(2^k P))   v₇   v₈₂₇   v₁₅₈₃
 1          6            2      0       0
 2          8            2      2       2
 3         10            2      2       2
```

Two patterns, both now theorems:

* the `2`-adic valuation increases by **exactly 2** per doubling
  (`Valuation.padicValNat_den_dblX_two`);
* the valuation at an **odd** prime already present is **constant**
  (`Valuation.padicValNat_den_dblX_odd`,
  `Valuation.padicValNat_den_dblIter_const`, and `N55.seven_val_orbit`).

The (doubly exponential) growth of the denominators therefore comes entirely
from *newly entering* primes, each of which enters — in this data — with
valuation exactly `2`.  The entry valuation is now known exactly: a good prime
`ℓ` enters with valuation `2·v_ℓ(num y)` (`padicValNat_den_dblX_good`), so the
observed value `2` reflects the fact that these primes divide the relevant
`y`-numerator exactly once — recorded as Conjecture 1 in `FUTURE_DIRECTIONS.md`.

### Numerical check of the entry formula

The theorem `padicValNat_den_dblX_good` predicts, for a good prime `ℓ` not yet
in the denominator, `v_ℓ(den x(2P)) = 2 v_ℓ(num y(P))`.  Checked for `N = 55`,
`P = (9,28)` over the first three doublings and the primes `7, 827, 1583, 263`:

```
step 0  l=7     predicted 2  actual 2
step 0  l=827   predicted 0  actual 0
step 0  l=1583  predicted 0  actual 0
step 1  l=827   predicted 2  actual 2
step 1  l=1583  predicted 2  actual 2
step 1  l=263   predicted 0  actual 0
step 2  l=263   predicted 0  actual 0
```

## 4. Sequence lookup

No OEIS query was performed (this environment has no network access).  The
denominator sequence for `E₅₅, P = (9,28)` begins
`1, 3136, 21498536380459264, …`, i.e. `e_k² ` with `e_k = 1, 56, 146623620, …`;
we make no claim about its presence in OEIS.

## 5. What the evidence suggested, and what was then proved

| observation | status |
|---|---|
| `7 ∣ den x(2P)` for `E₅₅`, `7` good | proved (`N55.not_onlyBadPrimes`) |
| good primes persist through the whole orbit | proved (`dvd_den_dblIter_of_dvd`, `N55.seven_dvd_den_orbit`) |
| denominators are squares, `y`-denominators cubes | proved (`exists_den_param`) |
| a prime enters iff the point reduces to `O` | proved (`dvd_den_iff_no_affine_reduction`) |
| odd-prime valuations are frozen, `v₂` grows by 2 | proved (`Valuation.lean`) |
| failure happens for infinitely many `N` | proved (`Family.infinite_counterexamples`) |
| every integral point with a good prime dividing `y` refutes the conjecture | proved (`Criterion.not_onlyBadPrimes_of_intPoint`) |
| a good prime enters exactly when it divides `num(y)`, with valuation `2·v_ℓ(num y)` | proved (`Valuation.padicValNat_den_dblX_good`, `good_prime_dvd_den_dblX_iff`) |
| the entering primes divide `num(y)` only once (so entry valuation is always 2) | open (Conjecture 1) |
