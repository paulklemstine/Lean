# Computational evidence — NET-90 symmetric-mixture bump

All numbers below were produced by exact rational arithmetic (Python `fractions`) on the
*model* studied in the Lean files: a context built from `m` keys with sorted profile `a`
and `l` keys with sorted profile `b`, whose top-`k` head mass is the sup-convolution

```
mixHead(a,b,m,l,k) = max_{j ≤ k} ( headMass(a, min(j,m)) + headMass(b, min(k-j,l)) )
```

and whose knee is the least `k` with `mixHead ≥ τ · (headMass(a,m) + headMass(b,l))`,
gate `τ = 0.98` throughout (the experimental gate).

**Status of these numbers.** They are exploratory computations, *not* verified artefacts,
except where a corresponding Lean theorem is named — those cases are marked ✅ and are
proved without `sorry` in `Catalog/Probability/`.

## 1. Ratio sweep at fixed total key count (`2N = 128`, self-mixture `a = b`)

| profile | pure (128,0) | 25/75 (32,96) | 50/50 (64,64) | 75/25 (96,32) |
|---|---|---|---|---|
| `(1/2)^i` | 6 | 12 | 12 | 12 |
| `(4/5)^i` | 18 | 35 | **36** | 35 |
| `1/(i+1)^2` | 25 | 37 | **41** | 37 |
| `1/(i+1)^3` | 5 | 9 | 9 | 9 |

Every interior arm is bumped above both endpoints, and for the slowly decaying profiles
the balanced arm is the strict maximum — the qualitative shape reported in NET-90.

✅ Row 1 is a theorem: `kstar_geomHalf_eq_six` (6) and `mixKnee_geomHalf_eq_twelve` (12),
for all key counts `≥ 16` per side.
✅ The ordering "interior arms ≤ balanced arm" is a theorem for *every* antitone profile:
`balanced_maximises_knee`.

## 2. Full sweep, profile `(4/5)^i`, `2N = 128`

| m (code keys) | 0 | 8 | 16 | 32 | 48 | 64 | 80 | 96 | 112 | 120 | 128 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| knee | 18 | 23 | 31 | 35 | 36 | **36** | 36 | 35 | 31 | 23 | 18 |

A single symmetric unimodal bump: flat shoulders at the endpoints, a plateau at the top,
maximum attained at the balanced point.  This refutes all three pre-registered shapes
(linear, dip, monotone) on a second profile, independently of the geometric instance
formalised in Lean.

## 3. Counterexample hunt: does the bump ever invert?

Searching self-mixtures with *antitone* profiles, no split was found whose knee exceeds
the balanced knee — consistent with `balanced_maximises_knee`.  Non-antitone profiles are
outside the theorem's hypotheses and are exactly where the comparison should be expected
to fail; the hypothesis is therefore load-bearing rather than decorative.

## 4. Mass, not block count: the shoulder mechanism

Self-mixture of `(1/2)^i` against a *scaled copy* `δ · (1/2)^i`, 64 keys each side:

| δ | 1 | 1/10 | 1/100 | 1/1000 |
|---|---|---|---|---|
| knee | 12 | 10 | 7 | 6 |

The bump is a function of the **mass ratio**, not of the key counts: at `δ = 1/1000` the
minority owns half of all keys yet the knee is exactly the pure value `6`.

✅ Theorem: `mixKnee_lightMinority_eq_six` (δ = 1/1000, any key counts ≥ 16 per side).
✅ General mechanism: `mixKnee_le_kstar_inflated` and `minority_squeeze`.

## 5. Sequence search

The knee sequences here are gate- and profile-dependent step functions rather than
canonical integer sequences; no OEIS match was sought or claimed.

## 6. Script used

```python
from fractions import Fraction as F

def head(w, n): return sum(w[:n])

def knee_pure(w, n, tau):
    T = head(w, n)
    return next(k for k in range(n+1) if head(w, min(k, n)) >= tau*T)

def mixknee(wa, wb, m, l, tau):
    T = head(wa, m) + head(wb, l)
    for k in range(m+l+1):
        best = max(head(wa, min(j, m)) + head(wb, min(k-j, l)) for j in range(k+1))
        if best >= tau*T:
            return k
```

## 7. Cycle 4 — is the whole sweep ordered by imbalance?

Exploratory rational-arithmetic sweeps at total context `2N = 64`, gate `τ = 0.98`,
self-mixtures `mixknee(w, w, m, 64 - m)` (these numbers come from the script in §6 and are
**not** machine-checked; the Lean statement they motivated is
`mixKnee_majorise` in `Catalog/Probability/NET90MajorisationSweep.lean`):

| `m` (minority side) | 1 | 5 | 9 | 13 | 17 | 21 | 25 | 29 | 32 |
|---|---|---|---|---|---|---|---|---|---|
| `w i = (4/5)^i` | 18 | 21 | 24 | 28 | 32 | 34 | 35 | 35 | **35** |
| `w i = 1/(i+1)^2` | 16 | 18 | 21 | 25 | 28 | 29 | 30 | 31 | **31** |
| `w i = 1/(i+1)` | 58 | 57 | 57 | 57 | 58 | 58 | 59 | 59 | **59** |

Two readings.

1. For the two summable, genuinely decaying profiles the sweep is monotone increasing in
   `m` all the way to the balanced arm — and *strictly* increasing over most of the range
   for `1/(i+1)^2` (16, 16, 16, 17, 18, 19, 19, 20, 21, 22, 23, 24 for `m = 1 … 12`).
   This is the fine-grid regime in which the open strictness conjecture of
   `FUTURE_DIRECTIONS.md` §1 should hold; the geometric profile `(1/2)^i` used for the
   exact Lean instances has too coarse a grid for strictness (its interior is a plateau).
2. The harmonic profile shows `k*(1, 63) = 58 > 57 = k*(5, 59)`: an *unconditional*
   monotone-in-imbalance claim is false.  This is exactly why `mixKnee_majorise` carries
   the side condition `k*(more balanced) ≤ 2m`: at `m = 1` it reads `57 ≤ 2`, which fails,
   so the anomaly lies outside the theorem's hypotheses.  The side condition is therefore
   load-bearing, not decorative.

## 8. Cycle 5 — three domains

Independent rational-arithmetic evaluation of the threefold sup-convolution
`mix3knee(w, w, w, m, l, n)` for `w i = (1/2)^i` at gate `τ = 0.98` (again exploratory,
not machine-checked; the corresponding Lean theorem *is*
`mix3Knee_geomHalf_eq_eighteen`):

| sides `(m, l, n)` | `(16,16,16)` | `(20,30,25)` |
|---|---|---|
| three-domain knee | 18 | 18 |

together with the pure value 6 and the two-domain value 12 this gives the ladder
`6 → 12 → 18`, i.e. exactly `6·d` for `d` massive domains — no saturation.  The failing
budget 17 is decided by the balanced allocation `(6,6,5)`, whose leftover geometric tail
is exactly `1/16 · 2 = 1/8`; this is the content of the proved lemma
`pow_half_triple_lower`.

```python
def mix3knee(w, m, l, n, tau):
    T = head(w, m) + head(w, l) + head(w, n)
    for k in range(m + l + n + 1):
        best = max(head(w, min(j1, m)) + head(w, min(j2, l)) + head(w, min(k - j1 - j2, n))
                   for j1 in range(k + 1) for j2 in range(k + 1 - j1))
        if best >= tau * T:
            return k
```

## The `d`-domain sweep (cycle 6): where the `6·d` ladder breaks

Exploratory exact-rational sweep of the `d`-fold sup-convolution for `d` equally massive
geometric domains of `m = 16` keys each at gate `τ = 0.98` (Python `Fraction`, not
machine-checked; the corresponding Lean theorem *is* `mixNKnee_geomHalf` in
`Catalog/Probability/NET90DomainLadder.lean`):

| `d` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| swept knee | 6 | 12 | 18 | 23 | 29 | 35 | 41 | 46 | 52 | 58 | 63 | 69 |
| `⌈143·d/25⌉` | 6 | 12 | 18 | 23 | 29 | 35 | 41 | 46 | 52 | 58 | 63 | 69 |
| `6·d` | 6 | 12 | 18 | **24** | 30 | 36 | 42 | 48 | 54 | 60 | 66 | 72 |

The sweep agrees with the proved closed form `⌈143·d/25⌉` at every point, and separates
from the `6·d` reading of the three-domain cycle exactly at `d = 4` (23 versus 24).  The
mechanism is visible in the optimal allocation: it uses only blocks of `5` and `6` keys,
the two integers bracketing the tangency point of the chord `(7 − j)/64` with `(1/2)^j`,
which is why the per-domain rate is the non-integer `143/25 = 5.72`.

```python
from fractions import Fraction as F
def knee_d(d, m=16, tau=F(98, 100)):
    H = 2 * (1 - F(1, 2) ** m)                     # mass of one domain
    def best(k):                                   # balanced allocation is optimal
        q, r = divmod(min(k, d * m), d)
        js = [min(q + 1, m)] * r + [min(q, m)] * (d - r)
        return sum(2 * (1 - F(1, 2) ** j) for j in js)
    k = 0
    while best(k) < tau * d * H:
        k += 1
    return k
```
