# Computational Evidence — sharp constant for the EML polarisation product gate

Object under study (catalog `Applications/EMLDepthWidthTradeoff.lean`):

```
sqLayer h .eval u = (exp(h u) + exp(-h u) - 2) / h²          -- width-2 EML "squaring" layer
prodGate h x y    = (sqLayer h |>.eval (x+y) - sqLayer h |>.eval (x-y)) / 4
```

Writing `coshGap t = exp t + exp(-t) - 2 - t²` one has the exact identity

```
prodGate h x y - x y = ( coshGap(h(x+y)) - coshGap(h(x-y)) ) / (4h²).
```

Since `coshGap t = t⁴/12 + t⁶/360 + t⁸/20160 + …` is an *even* function with
non-negative Taylor coefficients, the two polarisation branches **cancel** to
leading order:

```
prodGate h x y - x y = h² ((x+y)⁴ - (x-y)⁴)/48 + O(h⁴)
                     = h² x y (x²+y²)/6      + O(h⁴).
```

The catalog's proved bound used the *sum* `((x+y)⁴+(x-y)⁴)/24`; the conjecture
asks for the *difference*.  Below: numerical data.

## 1. Sup over `[0,1]²` on a 41×41 grid

| `h`  | grid sup of \|error\| | `h²/3`     | `h²/3 + h⁴/21` |
|------|----------------------|------------|----------------|
| 0.5  | 0.0861610            | 0.0833333  | 0.0863095      |
| 0.25 | 0.0210084            | 0.0208333  | 0.0210194      |
| 0.1  | 0.0033384            | 0.0033333  | 0.0033335      |

The sup is attained at the corner `(1,1)` in every case (`err(0.5,1,1) = 0.0861610`
equals the grid sup exactly), confirming the "attained at `(1,1)`" part.

## 2. The `O(h⁴)` correction

`(sup − h²/3)/h⁴`:

| `h`  | ratio    |
|------|----------|
| 0.5  | 0.045247 |
| 0.25 | 0.044643 |
| 0.1  | 0.044476 |

Converging to `2/45 = 0.044444…`, which is exactly the next Taylor term
`(2h)⁶/(1440 h²)/h⁴ = 64/1440`.  So `sup = h²/3 + (2/45)h⁴ + O(h⁶)`, and the
constant `1/21 = 0.047619…` used in the formal statement is a safe over-estimate.

## 3. Counterexample hunt for the polarised two-sided bound

Scanning `h ∈ {0.1,…,0.5}` and a 21×21 grid on `[0,1]²`, we tested

```
h² ((x+y)⁴ - (x-y)⁴)/48  ≤  prodGate h x y - x y  ≤  h² ((x+y)⁴ - (x-y)⁴)/24 .
```

* sign violations (`error < 0`): **0**
* max observed ratio `error / (h²((x+y)⁴-(x-y)⁴))`: `0.021540`  (bound `1/24 = 0.041667`)
* min observed ratio: `0.020833…`  (bound `1/48 = 0.020833…`, attained in the limit)

No counterexample.  Note the *lower* bound `1/48` is attained (as `h → 0`), so
`((x+y)⁴-(x-y)⁴)/48` — not `/24` — is the genuinely sharp local constant; the
conjecture's `/24` is a valid but 2× lossy upper bound.  Both are proved.

## 4. Degenerate line `y = 0`

`prodGate h x 0 = 0 = x·0` identically, so the error is *exactly* `0` there,
whereas the catalog's sum bound `h²((x+0)⁴+(x-0)⁴)/24 = h²x⁴/12` is strictly
positive.  This is the cleanest witness that the difference form is the right
shape.

## 5. Closed form for the supremum (post-hoc check)

The formalisation of §10 of the Lean file gives the *exact* supremum
`(exp(2h) + exp(-2h) - 2 - 4h²)/(4h²)`.  Checking against the grid data of §1:

| `h`  | closed form | grid sup (41x41) |
|------|-------------|------------------|
| 0.5  | 0.086161    | 0.086161         |
| 0.25 | 0.021008    | 0.021008         |
| 0.1  | 0.003338    | 0.003338         |

The two columns agree to the printed precision, as they must: `(1,1)` is a grid
point and the theorem says the maximum sits there.

## 6. Scalar debiasing probe

Leading errors at the two probe points used in §11:

| point     | product `x y` | leading error coefficient `x y (x²+y²)/6` |
|-----------|---------------|-------------------------------------------|
| `(1,1)`   | `1`           | `1/3   = 0.33333` |
| `(1,1/2)` | `1/2`         | `5/48  = 0.10417` |

If a single gain `lam` could cancel the second-order error, the two coefficients
would have to be in the same ratio as the products, i.e. `1 : 1/2`.  They are in
ratio `1 : 0.3125`.  The mismatch `1/3 - 2·(5/48) = 1/8` is exactly the quantity
that drives the lower bound `h²/100` proved in `no_scalar_debiasing`.

## 7. OEIS

No integer sequence arises; the relevant coefficient list is
`2/(2k)!` (Taylor coefficients of `2cosh`), i.e. denominators
`1, 2, 24, 720, 40320, …` = `A010050`-adjacent factorials `(2k)!` (OEIS **A010050**:
`1, 2, 24, 720, 40320, 3628800, …`).  No new sequence.

## 8. Affine read-out barrier (second cycle)

Evidence behind `no_affine_debiasing` in
`Catalog/Bridges/EMLAffineReadoutBarrier.lean`.

### 8.1 The two probes disagree on the quartic-to-bilinear ratio

`A = prodGate h 1 1`, `B = prodGate h (1/2) (1/2)`; a single gain `lam` would have
to satisfy `lam·A = 1` **and** `lam·(4B) = 1`.

| `h`   | `A − 1`     | `h²/3`      | `4B − 1`    | `h²/12`     | `A − 4B`    | `h²/4`      |
|-------|-------------|-------------|-------------|-------------|-------------|-------------|
| 0.5   | 0.08616127  | 0.08333333  | 0.02100772  | 0.02083333  | 0.06515355  | 0.0625      |
| 0.2   | 0.01340465  | 0.01333333  | 0.00333778  | 0.00333333  | 0.01006687  | 0.01        |
| 0.1   | 0.00333778  | 0.00333333  | 0.00083361  | 0.00083333  | 0.00250417  | 0.0025      |
| 0.05  | 0.00083361  | 0.00083333  | 0.00020835  | 0.00020833  | 0.00062526  | 0.000625    |
| 0.01  | 3.33338e-05 | 3.33333e-05 | 8.33336e-06 | 8.33333e-06 | 2.50004e-05 | 2.5e-05     |

The last two columns are the certified gap `A − 4B ≥ 4h²/21` of the Lean proof
(here `≈ h²/4`), which is what forces `|lam| < 1/2` and then a contradiction.

### 8.2 How much can an affine read-out actually buy?

Unverified numerical exploration (not a Lean check).  In the `h → 0` limit the
best achievable leading constant is

`c* = min_{a,b,c,d} sup_{[0,1]²} | a·xy + b·x² + c·y² + d + xy(x²+y²)/6 |`,

the leading error of `lam = 1 + a h²`, `mu = b h²`, `nu = c h²`, `kappa = d h²`.
A random search on a 61×61 grid gives `c* ≈ 0.0417` at
`(a,b,c,d) ≈ (−0.314, −0.010, −0.010, 0.042)`, versus `1/3 ≈ 0.3333` for the raw
gate.  So an affine read-out buys about a factor `8` — but not a change of order,
exactly as `no_affine_debiasing` asserts.  The proved constant `1/210 ≈ 0.00476`
is a factor `≈ 8.8` below this numerically observed optimum, i.e. the theorem is
correct in order and conservative in constant.

## 9. Third cycle: universal generators and chained gates

### 9.1 The universal quartic constant (`polGate_sSup_asymptotic`)

For an even generator `g(t) = t² + gap t` with `gap` monotone on `[0,∞)`, the
proved closed form is `sup_{[0,1]²}|error| = gap(2h)/(4h²)`, attained at `(1,1)`.
Two sanity instances, evaluated directly:

| generator | `gap` | predicted sup | leading constant |
|---|---|---|---|
| EML (`2cosh − 2`) | `coshGap t` | `coshGap(2h)/(4h²)` | `4·(1/12) = 1/3` |
| pure quartic | `c t⁴` | `4 c h²` *(exact, all `h`)* | `4c` |
| square activation | `0` | `0` | `0` |

The pure quartic row is exact with no remainder, which is why the `O(h⁴)` in the
EML statement is attributed to the sextic and higher coefficients of `2 cosh`.

### 9.2 Chained gates: measured constant (`prodTree3_error`)

Grid scan of `|prodGate h (prodGate h x y) z − x y z|` over a `61³` grid of
`[0,1]³` (unverified numerics; the Lean theorem certifies the bound `3h²/4`):

| `h`  | `max error / h²` | maximiser | single-gate `error / h²` |
|------|------------------|-----------|--------------------------|
| 0.25 | 0.68666          | (1,1,1)   | 0.33612                  |
| 0.2  | 0.67933          | (1,1,1)   | 0.33512                  |
| 0.1  | 0.66979          | (1,1,1)   | 0.33378                  |
| 0.05 | 0.66745          | (1,1,1)   | 0.33344                  |
| 0.01 | 0.66670          | (1,1,1)   | 0.33334                  |

The measured constant converges to `2/3 = 2 × 1/3`: exactly *additive* in the
gate count, with no multiplicative compounding, and the maximiser stays at the
corner.  The proved constant `3/4` is therefore correct in order and conservative
by about `13%`; the source of the slack is the operand bound `33/32` used for the
outer gate's box estimate.
