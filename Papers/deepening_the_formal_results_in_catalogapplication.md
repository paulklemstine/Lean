# Computational evidence for the quantum EML scalar-log root

All claims listed here as **verified** are backed by Lean proofs in
`Catalog/NumberTheory/EMLQuantumTaylorCertificates.lean` and
`Catalog/NumberTheory/EMLQuantumScalarLogRootIsolation.lean` that compile with
no `sorry`.  Numbers in the exploratory tables below were produced with
floating-point / exact-rational scratch computations and are **not** by
themselves verification; they were used only to choose the rational endpoints
and bound constants that the Lean proofs then certify.

## 1. The equation

For real `t`, `‖log (1 + t i)‖² = f(t)` with

```
f(t) = (log (1 + t²) / 2)² + (arctan t)².
```

`f` is strictly increasing on `[0, ∞)`, `f(0) = 0`, `f(t) → ∞`, so there is one
positive solution of `f(t) = 1`.

## 2. Small-case table (exploratory, float)

| t        | f(t) − 1        |
|----------|-----------------|
| 1.2000   | −3.36 · 10⁻²    |
| 1.2200   | −1.05 · 10⁻²    |
| 1.2288   | −2.75 · 10⁻⁴    |
| 1.2290   | −4.35 · 10⁻⁵    |
| 1.229037 | −5.9 · 10⁻⁸     |
| 1.229038 | +5.4 · 10⁻⁷     |
| 1.2292   | +1.88 · 10⁻⁴    |
| 1.2500   | +2.44 · 10⁻²    |

Bisection gives `t* ≈ 1.2290375625139…`.

## 3. Certified enclosure (verified in Lean)

Using the two-sided Taylor certificates (arctan to orders 5 and 7, log to
order 5 with a geometric-tail remainder, together with `Real.log_two_*_d9` and
`Real.pi_*_d6`) the following are **proved**:

```
f(1.2290370) ≤ (0.9204946900 / 2)² + 0.8877904749² < 1
f(1.2290381) ≥ (0.9204956699 / 2)² + 0.8877906457² > 1
```

hence `t* ∈ [1.2290370, 1.2290381]`, an interval of width `1.1 · 10⁻⁶`.
Earlier catalog instalments certified only `[6/5, 5/4]` (width `1/20`).

## 4. Counterexample / rationality hunt

Scanning denominators `q = 1, …, 4000`, the first fraction `p/q` lying inside
the certified interval is `1583/1288 = 1.22903726…`.  Therefore no rational of
denominator `≤ 1287` can equal `t*`.  This finite check is redone inside Lean
by `decide` on

```
∀ q < 1288, 0 < q → 12290381 * q < ((12290370 * q + 9999999) / 10000000) * 10000000
```

(“the scaled interval contains no integer”), and is the arithmetic core of the
proved theorem `QuantumEML.scalarLogRoot_ne_rat_of_den_le`.

No counterexample was found to any statement that was subsequently formalised.

## 5. Derivative data (exploratory, float; the bound is proved)

| t     | f′(t) = (t log(1+t²) + 2 arctan t)/(1+t²) |
|-------|-------------------------------------------|
| 1.00  | 1.132                                     |
| 1.229 | 1.171                                     |
| 1.50  | 1.154                                     |

The Lean proof only needs `f′ ≥ 2/3` on `[1, 3/2]`, which is proved from
`log (1 + t²) ≥ log 2` and `arctan t ≥ π/4`.  This yields the effective
isolation inequality `|t − t*| ≤ (3/2)|f(t) − 1|` on `[1, 3/2]`.

## 6. Sequence search

The digit sequence of `t*` (1, 2, 2, 9, 0, 3, 7, 5, 6, 2, 5, …) was not matched
to any OEIS entry; we make no claim about its appearance there.

## 7. Hermitian rigidity: numerical sanity checks (exploratory) and what is proved

For the matrix statements of
`Catalog/NumberTheory/EMLQuantumHermitianRigidity.lean` the relevant data are
purely spectral, so only two numbers matter:

| quantity | float value | certified in Lean |
|----------|-------------|-------------------|
| `t*`     | 1.2290375625…| `1 < t* < √2` (this file), `t* ∈ [1.2290370, 1.2290381]` (isolation file) |
| `t*²`    | 1.5105333…   | `1 < t*² < 2` (`one_lt_scalarLogRoot_sq`, `scalarLogRoot_sq_lt_two`) |

Consequences checked numerically first and then **proved**:

* `tr H` for admissible `H` in dimension `n` takes exactly the `n + 1` values
  `t*(2k − n)`, e.g. for `n = 3`: `−3.687, −1.229, +1.229, +3.687` — never `0`,
  which is the odd-dimension obstruction.
* `tr H² = n t*² ∈ {1.5105, 3.0211, 4.5316, …}` — never an integer for
  `n ≤ 10` in floating point, consistent with (but not a proof of) the
  transcendence expectation.
* Integer Hamiltonians: a brute-force float scan over all symmetric `2 × 2`
  integer matrices with entries in `[−5, 5]` found none with `H² = t*² I`, as
  the proved integrality obstruction requires: `t*²` is trapped strictly
  between the consecutive integers `1` and `2`.

## 8. Denominator obstruction: where the certified interval runs out

Write `L = 1.2290370²` and `U = 1.2290381²`, the endpoints of the certified
enclosure of `t*²` (`scalarLogRoot_sq_mem_Icc`, proved in
`Catalog/NumberTheory/EMLQuantumDenominatorObstruction.lean`):

```
1.510531947369 ≤ t*² ≤ 1.510534651252 .
```

A Hermitian matrix whose entries are Gaussian rationals with common denominator
`q` forces `q² t*²` to be a nonnegative integer (row quantization
`∑_j |H_{ij}|² = t*²` after clearing denominators).  So the obstruction holds for
exactly those `q` for which `[q²L, q²U]` contains no integer:

| q  | q²L          | q²U          | integer inside? |
|----|--------------|--------------|-----------------|
| 1  | 1.510531947  | 1.510534651  | no              |
| 2  | 6.042127789  | 6.042138605  | no              |
| 3  | 13.594787526 | 13.594811861 | no              |
| 4  | 24.168511158 | 24.168554420 | no              |
| 32 | 1546.784714  | 1546.787483  | no              |
| 64 | 6187.138856  | 6187.149932  | no              |
| 65 | 6381.997478  | 6382.008902  | **yes** (6382)  |

Exploratory scanning (exact rational arithmetic) shows `q = 65` is the first
failure, so `q ≤ 64` is the exact reach of the present enclosure.  The finite
check for all `1 ≤ q ≤ 64` is **verified in Lean** by exact integer arithmetic
(`no_integer_multiple`, discharged by `decide`), not merely by the scratch
computation above; the table itself is exploratory.

A sharper enclosure of width `w` extends the range to `q ≲ w^{-1/2}`, which is
the content of next-cycle Conjecture A in `FUTURE_DIRECTIONS.md`.

## 9. Stratum separation and the second arithmetic channel (cycle 7)

Two numbers govern the new results:

| quantity | float value | status |
|----------|-------------|--------|
| `2 t*`   | 2.4580751250… | **proved** to be a lower bound for the Frobenius distance between admissible Hamiltonians of different trace (`two_scalarLogRoot_le_frobenius_dist`), and attained in dimension one |
| `1287`   | —            | **proved** denominator bound for `t*` (earlier instalment), reused as `q ≤ 1287 / n` in odd dimension |

Exploratory checks made before formalizing, all consistent with the proved statements:

* random pairs of `2 × 2` and `3 × 3` orthogonal projections `P, Q` of different rank give
  `‖P − Q‖_F² ≥ 1` with equality approached by rank-`0`/rank-`1` pairs sharing a
  one-dimensional near-overlap; equal-rank pairs give values arbitrarily close to `0`,
  matching the earlier `exists_distinct_close_mem`;
* consequently `‖H − K‖_F = 2t*‖P − Q‖_F ≥ 2t* ≈ 2.458` across strata, and the pair
  `(t*, −t*)` in dimension one gives exactly `2t*`;
* the reach of the trace channel, `⌊1287/n⌋`, is `1287, 429, 257, 183, 141` for
  `n = 1, 3, 5, 7, 9`, against the dimension-independent row-channel reach `64`;
* squared moduli in the imaginary quadratic orders are `a² + d b²` (for `ℤ[√−d]`) and
  `a² − ab + b²` (Eisenstein): both are rational integers, hence trapped away from
  `t*² ∈ (1, 2)` after summing over a row, which is the content of the new integral row
  obstruction.

The tables above are exploratory; the corresponding statements are the theorems named in
parentheses, all of which compile with no `sorry`.
