# Computational evidence — fork channels g / Is / A / X

All numbers below were produced with **exact rational arithmetic** (Python `Fraction`,
no floating point except in the printed approximations). They are *supporting*
evidence: every claim that this cycle asserts is separately proved in Lean 4 in
`Catalog/MachineLearning/ForkChannel*.lean`, without `sorry` and with only the
standard axioms.

## 0. Setup

A fork is `N = n+1` independent bits with `P(bit = true) = p`. A channel is a scalar
readout; its strength is the squared Pearson correlation with the designated bit `x₀`:

```
chan(F) = Cov(x₀, F)² / (Var x₀ · Var F).
```

The four readouts are OR (`g`), AND (`A`), parity (`X`), Hamming weight (`Is`).

## 1. Small-case brute force vs. the closed form

Exhaustive enumeration of all `2^N` bit patterns with exact product weights, for
`N = 2 … 10` and `p ∈ {1/4, 1/3, 1/2, 2/3, 3/4, 4/5}` (54 configurations, 216 channel
values). Every single value matched the predicted profile

```
Φ(t, n) = tⁿ / (1 + t + ⋯ + tⁿ),
A = Φ(p, n),  g = Φ(1-p, n),  X = Φ((1-2p)², n),  Is = Φ(1, n) = 1/(n+1).
```

Result: **all matched (0 mismatches)**. This is the empirical form of the Lean
theorems `aChan_eq`, `gChan_eq`, `xChan_eq`, `isChan_eq`.

The two failure modes recorded in the incoming ledger (unnormalised weights,
non-summing distributions) cannot occur here: the total mass is the theorem `E_one`,
and the correlation is scale-free.

## 2. Counterexample hunt for a crossover in `n`

For every bias `p = k/40`, `k = 1 … 39`, and every fork size `n = 1 … 40`, we recorded
the sign of `A − X` and of `A − g`.

```
biases with an n-dependent sign flip: []
```

No bias produces a crossover at any size — in particular there is no `n = 8`
crossover. The Lean theorem `aChan_xChan_crossover_free` proves this for *all* biases
and *all* sizes: the sign is `sign(p − 1/4)` for `A − X` and `sign(p − 1/2)` for
`A − g`, both independent of `n`.

## 3. The `X / g` ratio (H3)

| n | `X/g` at `p = 1/3` | `X/g` at `p = 4/5` |
|---|---|---|
| 4  | 1.786682e-03 | 8.446465e+00 |
| 8  | 1.546366e-06 | 8.816859e+01 |
| 12 | 1.218755e-09 | 9.254667e+02 |
| 16 | 9.442950e-13 | 9.715163e+03 |
| 20 | 7.292168e-16 | 1.019859e+05 |
| 24 | 5.627578e-19 | 1.070607e+06 |

At `p = 3/4` the ratio is the constant `1` for every `n` (checked exactly for
`n = 1 … 29`; proved in Lean as `xChan_eq_gChan_iff` / `critical_three_quarters`).

So the ratio never settles at `2`: it decays geometrically below `p = 3/4`, is
identically `1` at `p = 3/4`, and grows geometrically above. Lean:
`xChan_div_gChan_not_tendsto_two`.

## 4. The closed 25-bit table (`N = 25`, `n = 24`, `p = 1/3`)

| channel | exact value | approx |
|---|---|---|
| `Is` | `1/25` | 4.000000e-02 |
| `g`  | `16777216/847255055011` | 1.980185e-05 |
| `A`  | `1/423644304721` | 2.360471e-12 |
| `X`  | `1/89737248461481573596281` | 1.114364e-23 |

Ordering `X < A < g < Is`. These four entries and the ordering are Lean theorems
`table25_xChan`, `table25_aChan`, `table25_gChan`, `table25_isChan`,
`table25_ordering`.

## 5. Sequence remark

`Is(n) = 1/(n+1)` is the harmonic sequence; the AND channel at `p = 1/2` is
`1/(2^{n+1} − 1)`, whose denominators `1, 3, 7, 15, 31, …` are the Mersenne numbers
(OEIS A000225). No further sequence lookups were needed: all four channels are
closed rational forms in `p` and `n`, so there is no unidentified integer sequence
in this cycle.

## 6. Reproduction script

```python
from fractions import Fraction as F
from itertools import product

def brute(N, p):
    q = 1 - p
    xs = list(product([0, 1], repeat=N))
    def Ew(f):
        s = F(0)
        for x in xs:
            w = F(1)
            for b in x:
                w *= p if b else q
            s += w * f(x)
        return s
    ch = {'A': lambda x: F(all(x)), 'g': lambda x: F(any(x)),
          'X': lambda x: F(sum(x) % 2), 'Is': lambda x: F(sum(x))}
    c0 = lambda x: F(x[0])
    out = {}
    for k, f in ch.items():
        cov = Ew(lambda x: c0(x) * f(x)) - Ew(c0) * Ew(f)
        v0 = Ew(lambda x: c0(x) * c0(x)) - Ew(c0) ** 2
        vf = Ew(lambda x: f(x) * f(x)) - Ew(f) ** 2
        out[k] = cov * cov / (v0 * vf)
    return out

def Phi(t, n):
    return t ** n / sum(t ** k for k in range(n + 1))

def pred(N, p):
    n = N - 1
    return {'A': Phi(p, n), 'g': Phi(1 - p, n),
            'X': Phi((1 - 2 * p) ** 2, n), 'Is': Phi(F(1), n)}

# closed-form check
assert all(brute(N, p) == pred(N, p)
           for p in [F(1,4), F(1,3), F(1,2), F(2,3), F(3,4), F(4,5)]
           for N in range(2, 11))

# crossover hunt
flips = [F(k,40) for k in range(1,40)
         if len({Phi(F(k,40), n) > Phi((1-2*F(k,40))**2, n) for n in range(1,41)}) > 1]
assert flips == []
```

## Addendum (second cycle): product universality and symmetric optimality

Two new theorems were added this cycle; both were also checked numerically in exact
rational arithmetic before and after formalisation (script `/tmp`-local, reproduced
below), by brute-force enumeration of all `2^N` bit patterns with exact product
weights — no floating point anywhere.

**1. Product-readout universality** (`ForkChannel.leak_prodCh`).
For coordinate functions `c(true) = a`, `c(false) = b` taken from
`(1,0), (0,1), (-1,1), (2,-3), (5,1), (1/2,3)`, biases
`p ∈ {1/5, 1/3, 2/5, 1/2, 3/4}` and sizes `N = 2..8`, the exact leakage of
`∏ᵢ c(xᵢ)` was compared with `Φ(m²/s, N-1)` where `m = pa + (1-p)b` and
`s = pa² + (1-p)b²`:

```
checks: 210   mismatches: 0
```

**2. Symmetric optimality** (`ForkChannel.leak_le_isChan_of_symm`).
For random symmetric readouts (a random rational value attached to each Hamming
weight `0..N`), biases `p ∈ {1/3, 1/2, 3/5}` and sizes `N = 2..7`:

```
checks: 108   violations of leak ≤ 1/N: 0   equalities: 1
```

The single equality case occurred for a readout affine in the Hamming weight; this is
now a theorem, `ForkChannel.leak_eq_isChan_iff_affine_wCh`, so both the inequality and
its equality case are proved.

Reproduction script:

```python
from fractions import Fraction as F
from itertools import product

def leak(p, N, Fun):
    def E(g):
        tot = F(0)
        for x in product([0, 1], repeat=N):
            w = F(1)
            for b in x:
                w *= (p if b else 1 - p)
            tot += w * g(x)
        return tot
    x0 = lambda x: F(x[0])
    EF, Ex = E(Fun), E(x0)
    cov = E(lambda x: x0(x) * Fun(x)) - Ex * EF
    varF = E(lambda x: Fun(x) * Fun(x)) - EF * EF
    varx = Ex - Ex * Ex
    return F(0) if varF == 0 else cov * cov / (varx * varF)

def Phi(t, n):
    return t ** n / sum(t ** k for k in range(n + 1))
```

## Addendum — exact-rational corroboration of the total-leakage sum rule

Before formalising `ForkChannel.total_leak_le_one`, the sum rule was checked by exact
rational brute force (`fractions.Fraction`, no floating point) over the full space
`Bool^N`:

* **Random readouts.** `N ∈ {2,3,4}`, biases `p ∈ {1/5, 1/3, 1/2, 3/4}`, ten random
  integer-valued readouts per pair (values drawn uniformly from `-5..5`, constant
  readouts discarded): **119 checks, 0 violations** of
  `∑ᵢ corrSq(xᵢ,F) ≤ 1`; the maximum total observed was exactly `1`.
* **Affine readouts.** Same sizes and biases, five random readouts of the form
  `β + ∑ᵢ bᵢ·1[xᵢ]` per pair: **60 checks, 60 exact saturations**
  `∑ᵢ corrSq(xᵢ,F) = 1` — the saturation family later proved as
  `ForkChannel.total_leak_eq_one_iff_affine`.

The exploratory computation above is corroboration only; the statements themselves are
machine-checked in `Catalog/MachineLearning/ForkChannelLeakageSumRule.lean`
(`total_leak_le_one`, `total_leak_eq_one_sub_deficiency`,
`total_leak_eq_one_iff_affine`, `total_leak_wCh_eq_one`), with no `sorry` and only the
standard axioms.
