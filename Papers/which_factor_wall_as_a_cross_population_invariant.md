# Computational evidence — which-factor wall as a cross-population invariant

All numbers below come from double-precision floating-point exploration
(`python3`, natural logs unless "bits" is stated). They are **exploratory only**;
every claim that is asserted as a result has a separate, machine-checked Lean
proof in `Catalog/Algebra/WhichFactorWall*.lean`, and the correspondence is
listed in the last column of each table.

## Lab Notes 1 — the reported wall `0.4677` bits inverts to a 9.96% split

Bisection on `H₂(p) = 0.4677` bits over `p ∈ (0, 1/2]`:

```
root p* = 0.09959170773679446
```

so the reported wall is exactly the claim "the which-factor split is 9.959 %".
Rational bracketing values (bits):

| p | H₂(p) (bits) | vs 0.4677 |
|---|---|---|
| 1/16 = 0.0625 | 0.337290 | below |
| 1/12 = 0.08333 | 0.413817 | below |
| **p\*** ≈ 0.099592 | 0.467700 | = |
| 1/9 = 0.11111 | 0.503258 | above |
| 1/8 = 0.125 | 0.543564 | above |

The pair `(1/12, 1/9)` is the tightest dyadic-friendly bracket we could certify
from Mathlib's `log 2` bounds plus two Padé-type log inequalities; it is the
bracket proved in `wall_imbalance_bracket`.

## Lab Notes 2 — counterexample hunt for the proposed inverse-Lipschitz bound

Claim under test: `c(δ)|p−q| ≤ |H(p) − H(q)|` on `[δ, 1/2]`, `c(δ) = log((1−δ)/δ)`.

| δ | p | q | c(δ)·\|p−q\| | \|ΔH\| | claim holds? |
|---|---|---|---|---|---|
| 0.25 | 0.50 | 0.25 | 0.27465 | 0.13081 | **no** |
| 0.10 | 0.50 | 0.40 | 0.21972 | 0.02014 | **no** |
| 0.05 | 0.30 | 0.35 | 0.14722 | 0.03658 | **no** |
| 0.40 | 0.50 | 0.40 | 0.04055 | 0.02014 | **no** |
| 0.01 | 0.50 | 0.49 | 0.04595 | 0.00020 | **no** |

The claim fails everywhere, not marginally: `c(δ)` is the *supremum* of
`|H′|` on the interval. The first row is the exact counterexample formalised in
`binEntropy_conjectured_lower_bound_false`, where the inequality reduces to the
false statement `log 27 ≤ log 16`.

## Lab Notes 3 — the quadratic law at balance

`2t² ≤ log 2 − H(1/2 − t) ≤ 4t²` (nats):

| t | log 2 − H(1/2−t) | 2t² | 4t² | inside? |
|---|---|---|---|---|
| 0.001 | 0.0000020 | 0.0000020 | 0.0000040 | yes |
| 0.01 | 0.000200 | 0.000200 | 0.000400 | yes |
| 0.05 | 0.005008 | 0.005000 | 0.010000 | yes |
| 0.10 | 0.020136 | 0.020000 | 0.040000 | yes |
| 0.20 | 0.082283 | 0.080000 | 0.160000 | yes |
| 0.25 | 0.130812 | 0.125000 | 0.250000 | yes |
| 0.40 | 0.368064 | 0.320000 | 0.640000 | yes |
| 0.49 | 0.637146 | 0.480200 | 0.960400 | yes |

The lower constant `2` is attained asymptotically as `t → 0` (ratios
1.0000, 1.0016, 1.0068 at `t = 0.001, 0.05, 0.10`), which is why the
square-root exponent in `imbalance_sqrt_stability` cannot be improved.
Formalised as `binEntropy_gap_two_sided`.

## Lab Notes 4 — sharpness of the two moduli (random search, 2·10⁵ pairs each)

```
max |p-q| / sqrt(|ΔH|/2)   over random p,q in [0,1/2] = 0.9996166
max |ΔH| / H(|p-q|)        over random p,q in [0,1/2] = 0.9999885
```

Both ratios approach `1` and never exceed it in 4·10⁵ samples: no counterexample
was found to either side of the two-sided law
`2|p−q|² ≤ |ΔH| ≤ H(|p−q|)` (`wall_modulus_two_sided`), and neither constant can
be improved.

## Lab Notes 5 — replication tolerance

With splits below `1/9`, the slope of the wall is at least `log 8 = 2.0794`
nats per unit imbalance, so a wall reported to `±0.01` bits (`= 0.006931` nats)
determines the split to `±0.006931/2.0794 = ±0.003333 = ±1/300`. Formalised
exactly (no rounding) as `wall_replication_tolerance`.

## OEIS

No integer sequence arises: all objects here are real-analytic (binary entropy
and its inverse). An OEIS search is not applicable.
