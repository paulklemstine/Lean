# Computational evidence: the `abc` quality spectrum of the Berggren tree

For a primitive Pythagorean triple `a² + b² = c²` we regard `A + B = C` with `A = a²`,
`B = b²`, `C = c²`.  Since `A, B, C` are pairwise coprime,

```
rad(a²b²c²) = rad(abc),      q(a,b,c) = log(c²) / log(rad(abc)).
```

All the numbers below were produced by exploratory scripts (trial division / Pollard rho).
They are **not** part of the formal development; the statements that are machine-checked are
listed at the end of this file.

## 1. Exhaustive scan of primitive triples (Euclid parameters `m < 600`)

72 871 primitive triples were enumerated (`m` up to 599, `gcd(m,n)=1`, `m-n` odd).

| statistic | value |
|---|---|
| smallest quality found | `0.69133` at `(294285, 304292, 423317)`, `rad = 18953716261568370` |
| largest quality found | `1.26590` at `(36207, 18424, 40625)`, `rad = 19118190` |
| triples with `q > 1` (`abc` hits) | 242 of 72871 (0.33 %) |
| runner-up hits | `1.26498` at `(239, 28560, 28561)`; `1.26198` at `(14553, 144896, 145625)`; `1.25903` at `(16375, 768, 16393)` |

Observations.

* No triple in the scan came anywhere near the record quality `≈ 1.63` of the known `abc` hits;
  the observed maximum is `≈ 1.266`.
* The minimum drifts slowly downwards towards `2/3`, exactly as the heuristic
  `rad(abc) ≈ abc ≈ c³/2` predicts: `2 log c / (3 log c - log 2) = 0.679` at `c ≈ 4·10⁵`.
* Hits are rare but do not die out.

## 2. The `A`-spine `(2k+1, 2k(k+1), 2k²+2k+1)`

| k | triple | rad(abc) | q |
|---|---|---|---|
| 1 | (3, 4, 5) | 30 | 0.9464 |
| 2 | (5, 12, 13) | 390 | 0.8598 |
| 3 | (7, 24, 25) | 210 | **1.2040** |
| 4 | (9, 40, 41) | 1230 | 1.0439 |
| 8 | (17, 144, 145) | 14790 | **1.0366** |
| 20 | (41, 840, 841) | 249690 | 1.0838 |
| 24 | (49, 1200, 1201) | 252210 | 1.1402 |
| 28 | (57, 1624, 1625) | 1504230 | 1.0396 |

The hypotenuses `5, 13, 25, 41, 61, …` are the centred square numbers (OEIS A001844).
Hits on the spine occur exactly when `k(k+1)` is unusually powerful.

## 3. The explicit hit family `n = d^(2^k) − 1`

For an odd base `d` the number `n = d^(2^k) − 1` is divisible by `2^(k+2)`, so
`rad(2n(n+1)) ≤ 2 rad(n) rad(d) ≤ n` once `d ≤ 2^k`; this forces `rad(abc) < c²`,
i.e. `q > 1`.  Base `d = 3`:

| k | n = 3^(2^k) − 1 | c = 2n²+2n+1 | rad(abc) | q |
|---|---|---|---|---|
| 1 | 8 | 145 | 14790 | 1.0366 |
| 2 | 80 | 12961 | 62601630 | 1.0550 |
| 3 | 6560 | 86080321 | 1389235666964430 | 1.0480 |
| 4 | 43046720 | 3706040291610241 | 183947336832664790626446040290 | 1.0640 |

Each step roughly squares the hypotenuse (`c(k+1) ≈ c(k)²/2`), so the family is doubly
exponentially sparse — a fact that is proved formally.

## 4. The `B`-spine (Pell branch)

Hypotenuses `5, 29, 169, 985, 5741, …` (OEIS A001653), satisfying `c(n+2) = 6c(n+1) − c(n)`,
with ratios `5.8, 5.8276, 5.8284, …` converging to the silver-ratio square
`(1+√2)² = 3 + 2√2 = 5.82842…`.  This is the growth law used in the formal file.

## 5. Counterexample hunt

* Searched for a triple with `q ≥ 2` (equivalently `rad(abc) ≤ c`): none found — consistent with
  `abc`, which forbids `q > 1 + ε` asymptotically.
* Searched for a triple with `q ≤ 2/3`: none found, and none can exist —
  `2ab ≤ c²` gives `rad(abc) ≤ abc ≤ c³/2 < c³`, which is proved formally
  (`BerggrenABC.two_thirds_lt_quality`).
* Searched the tree (BFS, `c ≤ 40625`) for the path to the record node: `CCCACCBC`, depth 8;
  this path is verified inside Lean.

## 6. What is machine-checked in Lean

`Catalog/Logic/BerggrenAbcQuality.lean` and `Catalog/Logic/BerggrenAbcSpectrum.lean` prove,
with no `sorry` and no extra axioms:

* `rad(a²b²c²) = rad(abc)` for every tree node, and that every node is a primitive
  Pythagorean (hence `abc`) triple;
* the criteria `q > 1 ↔ rad(abc) < c²`, `q < 2 ↔ rad(abc) > c`, and the rational-threshold
  versions;
* `q > 2/3` for every node (unconditional lower edge);
* `q < 2` for every node whose `abc`-product is not powerful (`abc ≤ rad(abc)²`);
* the exact radicals `30, 390, 210, 316470, 19118190` of the five explicit nodes above;
* `5/4 < q(36207,18424,40625) < 4/3`, and non-monotonicity of `q` under descent;
* infinitely many tree nodes with `q > 1`, for every odd base `d ≥ 3`;
* the conditional bounds `q ≤ 13/10` (effective `abc`) and `q ≤ 1 + 2ε` for large `c`
  (Masser–Oesterlé `abc`);
* `5^(n+1) ≤ c_n ≤ 5 (3+2√2)^n` along the Pell branch.
