# Computational evidence: denominator primes of `x(nP)` on Mordell curves

All Lean-verified statements live in `Catalog/Shared/MordellDenominatorPrimes.lean`,
`Catalog/Shared/MordellDenominatorValuations.lean` and
`Catalog/Shared/MordellDenominatorBarriers.lean`.  The material in *this* file is
**exploratory** (a rational-arithmetic sweep, not a machine-checked proof) except where it is
explicitly cross-referenced to a Lean theorem.

## 1. The core small case (Lean-verified)

`E_55 : y² = x³ + 55`, `55 = 5 · 11`, `P = (9, 28)` (`28² = 784 = 9³ + 55`).

Doubling with the affine group law (Mathlib's `WeierstrassCurve.Affine.Point`, formalised in
`mordell_double_xCoord`):

```
x(2P) = (x⁴ − 8Nx) / (4y²) = (6561 − 3960) / 3136 = 2601 / 3136,
2601 = 3² · 17²,      3136 = 2⁶ · 7².
```

`7 ∣ 3136` but `7 ∤ Δ = −432 · 55² = −1 306 800`, so `7` is a prime of **good** reduction that
nevertheless divides the denominator.  Lean: `counterexample_N55`, `not_onlyBadPrimesConj`,
and the sharp valuation `7² ∥ 3136` in `den_double_55_exact`.

## 2. Sweep over semiprime Mordell curves (exploratory)

For each semiprime `N = p·q` the first integral point `(x, y)` with `−20 ≤ x < 400` was found
by search, and the denominators of `x(nP)` for `n = 2, 3, 4` were computed in exact rational
arithmetic (`fractions.Fraction`).  Prime factors were extracted by trial division up to 10⁵;
one denominator retained an unfactored cofactor (marked).

| `N = p·q` | point `P` | denominators of `x(nP)` | primes in denominators | good-reduction primes present |
|---|---|---|---|---|
| 55 = 5·11 | (9, 28) | n=2: 3136; n=3: 656538129; n=4: 21498536380459264 | 2, 3, 7, 13, 73, 827, 1583 | 7, 13, 73, 827, 1583 |
| 15 = 3·5 | (1, 4) | n=2: 64; n=3: 33489; n=4: 575232256 | 2, 3, 61, 1499 | 61, 1499 |
| 21 = 3·7 | (no integral point with `x < 400`) | – | – | – |
| 35 = 5·7 | (1, 6) | n=2: 16; n=3: 2209; n=4: 7268416 | 2, 47, 337 | 47, 337 |
| 33 = 3·11 | (−2, 5) | n=2: 25; n=3: 8649; n=4: 75777025 | 3, 5, 31, 1741 | 5, 31, 1741 |
| 65 = 5·13 | (−4, 1) | n=2: 1; n=3: 86436; n=4: 199176769 | 2, 3, 7, 11, 1283 | 7, 11, 1283 |
| 77 = 7·11 | (no integral point with `x < 400`) | – | – | – |
| 91 = 7·13 | (−3, 8) | n=2: 256; n=3: 9199089; n=4: 13462206751744 | 2, 3, 337 (+ unfactored cofactor 13146686281) | 337 |
| 115 = 5·23 | (no integral point with `x < 400`) | – | – | – |
| 143 = 11·13 | (1, 12) | n=2: 64; n=3: 36481; n=4: 9072181504 | 2, 191, 5953 | 191, 5953 |
| 187 = 11·17 | (no integral point with `x < 400`) | – | – | – |

**Summary over the 7 curves that carry a small integral point.**

* "only `{2,3,p,q}`" holds: **0 / 7 (0 %)** — every single curve exhibits a good-reduction
  prime in a denominator already at `n ≤ 4`.
* `q` (the larger factor) occurs in some denominator: **0 / 7 (0 %)**.
* `p` (the smaller factor) occurs: **2 / 7 (28.6 %)** — and in *both* cases `p = 3`, which
  divides `Δ = −432N²` for trivial reasons.  Excluding `p = 3`, the observed rate at which a
  genuine odd prime factor of `N` shows up in a denominator is **0 / 5**.

(The mission brief quotes 54.5 % for `p`; that figure presumably comes from a different point
selection or a longer `n`-range.  The rate reported here is the one produced by the sweep
described above and should be read as such.)

## 3. Counterexample hunt against the universal claim

The claim tested is: *for `N = pq`, every prime dividing `den x(nP)` lies in `{2, 3, p, q}`.*
It fails on the very first curve tried (`N = 55`, `n = 2`) and on all seven curves in the
table.  The failure is not sporadic: `dvd_den_double_iff` shows `ℓ ∣ den x(2P) ⇔ ℓ ∣ y` for
every good prime `ℓ ≥ 5`, and `good_prime_realised` produces, for each such `ℓ`, an explicit
curve/point pair realising it (`N = ℓ² − 1`, `P = (1, ℓ)`).

## 4. Boundary probes

* Complete trichotomy (all Lean-verified): for an integral point with `y ≠ 0`,
  `ℓ ≥ 5` and `ℓ ∤ N` give `ℓ ∣ den x(2P) ↔ ℓ ∣ y` (`dvd_den_double_iff`);
  `3 ∤ N` gives `3 ∣ den x(2P) ↔ 9 ∣ y` (`three_dvd_den_double_iff`);
  `N` odd gives `2 ∣ den x(2P) ↔ 2 ∣ y`, and then `16 ∣ den x(2P)`
  (`two_dvd_den_double_iff`, `sixteen_dvd_den_double`).  Spot checks:
  `N = 17, P = (4,9)`: `den = 9`; `N = 199, P = (5,18)`: `den = 144`;
  `N = 28, P = (2,6)`: `den = 1`; `N = 35, P = (1,6)`: `den = 16`.
* `ℓ = 3`: `N = 8`, `P = (1, 3)` has `3 ∣ y`, `3 ∤ N`, and yet
  `x(2P) = (1 − 64)/36 = −7/4`; the `3`-part of `4y² = 36` is fully cancelled by the
  numerator.  Lean: `den_criterion_needs_five`.  This is why the criterion is stated for
  `ℓ ≥ 5`: mod `ℓ`, the numerator is `x⁴ − 8Nx ≡ −9Nx`, and `3 ∣ 9`.
* Absent bad primes: `N = 35`, `P = (1, 6)` gives `x(2P) = −279/144 = −31/16`, a pure power of
  two — neither `5` nor `7` appears.  Lean: `barrier_bad_primes_absent`,
  `factorisation_barrier`.
* Trivial denominator: `N = 65`, `P = (−4, 1)` gives `den x(2P) = 1` (`2P` is again integral),
  consistent with `v_ℓ(den x(2P)) = 2 v_ℓ(y)` and `y = 1`.

## 5. Sequence remarks

The denominators of `x(nP)` are squares of the terms of the elliptic divisibility sequence
attached to `(E_N, P)`; e.g. for `N = 55`, `P = (9,28)`: `1, 56², 25623², …`
(`3136 = 56²`, `656538129 = 25623²`).  No OEIS lookup was performed (no network access in this
environment), so no OEIS identifier is asserted here.  The perfect-square shape is, however,
exactly what `pow_dvd_den_double_iff` predicts at every good prime `ℓ ≥ 5`, since it forces
`v_ℓ(den x(2P)) = 2 v_ℓ(y)`.

## 6. Reproducing the sweep

```python
from fractions import Fraction as F

def add(P, Q, N):            # affine group law on y^2 = x^3 + N over Q
    if P is None: return Q
    if Q is None: return P
    (x1, y1), (x2, y2) = P, Q
    if x1 == x2 and y1 == -y2: return None
    m = (3*x1*x1)/(2*y1) if P == Q else (y1-y2)/(x1-x2)
    x3 = m*m - x1 - x2
    return (x3, m*(x1-x3) - y1)

N, P = 55, (F(9), F(28))
Q = P
for n in range(2, 5):
    Q = add(Q, P, N)
    print(n, Q[0].denominator)
# 2 3136
# 3 656538129
# 4 21498536380459264
```
