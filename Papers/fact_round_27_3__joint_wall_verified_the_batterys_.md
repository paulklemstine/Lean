# Computational evidence — factor blindness and plug-in bias

All numbers below are reproduced by `scripts/factor_blindness_evidence.py`
(standard library only, `random.seed(11)`).  The battery readout used throughout is the
four-field CRT-chained code with moduli `[3,5,7,11]`,

```
acc = 0;  for m in [3,5,7,11]:  acc = (acc*m + (p+q) % m)*m + (p*q) % m
```

which is the object formalised as `batteryCode [3,5,7,11]` / `battery4`.

> Status note: the tables here are *exploratory numerics*, not verified computations.
> Every claim that is asserted as a theorem in this project is proved in Lean; where a number
> below is only an experiment, it is labelled as such.

## 1. Reproducing the reported signature (observed ≈ null mean, z ≈ 0)

3995 ordered pairs of distinct primes drawn from the 250 primes in (50, 2000); label = "is the
second coordinate the bigger factor"; 200-shuffle permutation null.

| quantity | value |
|---|---|
| samples | 3995 |
| distinct code values | 3597 (90.0 %) |
| observed plug-in reading | **0.8985 bits** |
| permutation-null mean | **0.8996 bits** |
| null sd | 0.0046 |
| z | **−0.23** |

Same signature as the reported run (observed = null mean to within a fraction of a null sd),
only louder, because this sample is even sparser than the reported one.

## 2. The exact population reading is exactly zero

Over *all* 3540 ordered pairs of the first 60 primes above 50 — a swap-closed, off-diagonal
population — the plug-in reading computed on the whole population (no sampling) is

```
I(bigger ; four-field code) = 0.000000000000 bits
```

This is the numerical shadow of the theorem `galoisBlind_zero_leakage` /
`battery4_zero_leakage`: the value is not small, it is identically `0`.

Capacity is unaffected: the realised code alphabet on that population has
`log₂ 1711 = 10.74` bits of support, under the proved ceiling
`log₂((3·5·7·11)²) = 20.35` bits (`batteryCode_lt`, `battery4_capacity_ceiling`).

## 3. The estimator's one-sided bias (exact independence, truth = 0)

Labels and codes drawn independently (2 labels, 8 codes); mean plug-in reading over 300 runs:

| n | 2 | 4 | 8 | 16 | 64 | 256 | 1024 |
|---|---|---|---|---|---|---|---|
| mean reading (bits) | 0.4167 | 0.6114 | 0.5495 | 0.3769 | 0.0891 | 0.0187 | 0.0051 |

The reading is positive at every sample size although the truth is `0`, decaying like the
Miller–Madow rate `(|A|−1)(|B|−1)/(2n ln 2)`.  The one-sidedness is the proved fact
`mutualInfo_nonneg`; the exact zero-variance instance of it is `wall_was_bias`.

## 4. Divisor populations — and the sharp boundary at perfect squares

Population = all ordered factorisations `{(d, n/d) : d ∣ n}`.

| n | square? | ordered factorisations | I(bigger ; code) |
|---|---|---|---|
| 15 | no | 4 | 0.000000000000 |
| 483 = 21·23 | no | 8 | 0.000000000000 |
| 36 | **yes** | 9 | **0.102187170949** |
| 100 | **yes** | 9 | **0.102187170949** |

The non-square rows are `battery4_divisor_blind`.  The square rows show that the
off-diagonality hypothesis is *sharp*, not technical: the swap-fixed pair `(√n, √n)` breaks
the exact halving of the fibers and produces a strictly positive reading — consistent with
`mutualInfo_eq_zero_iff_product`, which says a nonzero reading requires a non-product table.

## 5. The sparse regime in closed form

When every sample carries a distinct code, the plug-in reading equals the label entropy
exactly:

| labels | plug-in reading | label entropy |
|---|---|---|
| `[1,1,0,0,0,1]` | 1.000000 | 1.000000 |
| `[1,1,1,1,0,0]` | 0.918296 | 0.918296 |
| `[1,0,0,0,0,0]` | 0.650022 | 0.650022 |

This is `sparse_mutualInfo`, and it explains row 1: the experimental reading `0.8985` sits
just below the label entropy `1.0000`, the deficit being caused by the 10 % of samples that
share a code.  In the injective limit the statistic is a function of the label counts alone,
so every permutation surrogate returns the same number and the null is a point mass —
`sparse_null_invariant`, `sparse_z_numerator_zero`.

## 6. Three factors: the symmetric group replaces the swap

Population: the six orderings of `(3, 5, 7)`; label: the full ordering pattern (an element of
`S₃`); readouts: a symmetric trace battery and a merely cyclic (`A₃`-invariant) one.

| readout | invariance group | reading (bits) |
|---|---|---|
| `(∑ vᵢ mod 13, ∏ vᵢ mod 17)` | `S₃` | 0.000000000000 |
| `v₀v₁² + v₁v₂² + v₂v₀² mod 101` | `A₃` | 1.000000000000 |

The first row is the measured face of `symmetricGroup_rank_zero_leakage` /
`battery_triple_blind` (proved: the reading is exactly `0` for *every* permutation-invariant
readout on such a population, not just this one).  The second row is the motivation for the new
direction A: an `A₃`-invariant readout reads exactly `log₂ [S₃ : A₃] = 1` bit, the conjectured
coset ceiling.

## 7. OEIS

No new integer sequence arises: the quantities of interest are cardinalities of divisor
populations (`A000005` shifted by ordering) and code alphabet sizes `(∏ mᵢ)²`.  No OEIS
lookup was needed, and none is claimed.
